class Video < Media
  
  require 'digest/sha1'

  has_many  :order_items, :foreign_key => 'item_id', :conditions => "item_type = #{OrderItem::TypeVideo}"

  #class methods

  def self.get(id)
    #this depends on whether video approval is enabled
    if Configuration.queue_new_videos
      self.approved.find_by_id(id)
    else
      self.find_by_id(id)
    end
  end

  def self.supported_video_type(uploaded_extension)
    Configuration.supported_video_types.include?(uploaded_extension)
  end

  def self.save_and_queue_video_job(uploaded_video_file, user)
    if user.disk_space_used.to_i < user.host_plan.disk_space_bytes.to_i
      video_file = VideoFile.new(uploaded_video_file)
      if video_file.size > 0
        unless video_file.type == :video
          status = 1
          raise
        end
        #allowed image type
        if Video.supported_video_type(video_file.file_extension)
          Video.transaction do
            begin
              video = Video.create(:title => video_file.filename, :state => 1,
                :user_id => user.id, :orig_file_ext => video_file.file_extension) #state 1 == 'uploaded to library'
              video.copy_uploaded_video_to_library(video_file.file)
              #video metadata
              video.get_metadata_from_video_file(video_file)
              #set prices and licenses
              video.license_id = user.default_upload_license
              video.price      = 1
              #add to user
              user.videos << video
              #schedule preview and thumbnail
              job = JobSpinner.spin_job do 
                Job.enqueue_onto_queue!(:long, BackgroundWorker, :process_uploaded_video, "Processs video #{video.title}", {:video_id => video.id})
              end
              video.job_id = job.id
              video.state = 3
              video.save!
              yield video if block_given? #if we ever need to access generated video
            rescue
              #something went wrong...clean up if necessary
              video.delete_files unless video.blank?
              #re-raise to propagate to controller
              raise
            end
          end
          status = 0
        else
          status = 1 #not supported image type
        end
      else
        status = 10
        logger.fatal(['Uploaded video file with size 0 in save_and_queue_video_job', video_file.to_yaml].join("\n"))
        #TODO email admin
      end
    else
      status = 2
    end
    status
  end

  def self.queue_new_media
    Configuration.queue_new_videos
  end

  #instance methods

  def copy_uploaded_video_to_library(source_file)
    self.filename = "#{id}#{orig_file_ext}"
    store_file    = original_file(self.filename)
    #create dir if it doesn't already exist
    FileUtils.mkdir_p(File.dirname(store_file)) unless File.exist?(File.dirname(store_file))
    #copy uploaded tmp file to library
    File.open(store_file, "wb") do |f|
      f.write(source_file.read)
    end
  end

  def original_file(use_this_file_name = nil)
    base_dir = File.expand_path("#{Rails.root}/images/videos/#{created_on.year.to_s}/#{created_on.month.to_s}/#{user_id}")
    if use_this_file_name.blank?
      File.join(base_dir, filename)
    else
      File.join(base_dir, use_this_file_name)
    end
  end

  #partition flv file location by year/month and user. Throw in a hash in the path to prevent guessing for flv file locations
  def flv_file(options = {})
    base = "/library/video/#{created_on.year.to_s}/#{created_on.month.to_s}/#{user_id}/#{id}u#{Digest::SHA1.hexdigest(created_on.to_s)}/#{id}.flv"
    if options[:full_path].nil?
      base
    else
      File.join("#{Rails.root}/public/", base)
    end
  end

  def flv_file_dir
    File.dirname(flv_file(:full_path => true))
  end

  def splash_file(options={})
    unless options[:full_path].nil?
      File.join(File.dirname(flv_file(:full_path => true)), "#{id}.jpg")
    else
      File.join(File.dirname(flv_file), "#{id}.jpg")
    end  
  end

  def thumbnail_file_public
    splash_file
  end

  def get_metadata_from_video_file(video_file)
    raise "Expected VideoFile but received #{video_file.class.to_s}" unless video_file.is_a? VideoFile
    self.width        = video_file.width
    self.height       = video_file.height
    self.duration     = video_file.duration.to_i
    self.aspect_ratio = (self.width.to_f / self.height.to_f).to_f if self.height.to_i > 0
    self.title        = File.basename(video_file.filename, File.extname(video_file.filename)) #remove extension
    self.file_size    = video_file.size
    self.file_type    = video_file.content_type
  end

  #override to delete video files
  def delete_files
    #TODO delete original file
    unless filename.blank?
      File.delete(splash_file(:full_path => true))   if File.exists?(splash_file(:full_path => true))
      File.delete(flv_file(:full_path => true)) if File.exists?(flv_file(:full_path => true))
      File.delete(original_file) if File.exists?(original_file)
    end
  end

  def convert_to_flash_and_generate_splash
    #create flv  dir if it doesn't already exist
    FileUtils.mkdir_p(flv_file_dir) unless File.exist?(flv_file_dir)
    #
    the_file = flv_file(:full_path => true)
    #convert
    video_file = MiniFfmpeg::Media.new(original_file)
    if block_given?
      video_file.convert_to_flv(the_file, Configuration.video_encode_width) {|progress| yield progress}
    else
      video_file.convert_to_flv(the_file, Configuration.video_encode_width)
    end
    #use generated FLV file to generate the preview file
    MiniFfmpeg::Media.new(the_file).generate_splash_image(splash_file(:full_path => true), Configuration.video_snapshot_offset)
    #record preview file dimensions
    splash = MiniMagick::Image.from_file(splash_file(:full_path => true))
    self.preview_width  = splash[:width]
    self.preview_height = splash[:height]
  end

  def buy_description
    "Video '#{description}'"
  end

  def is_one_of_my_resolutions(resolution)
    #TODO
    false
  end

end


class VideoFile < BaseUploadFile

  require 'mini_magick'

  attr_reader :width, :height, :duration, :type

  def initialize(file)
    super file
    video   = get_video
    #
    @width    = video.resolution.width
    @height   = video.resolution.height
    @duration = video.duration
    @type     = video.type
  end

  protected

  def get_video
    MiniFfmpeg::Media.new(@file.local_path)
  end


end

