class Audio < Media

  require 'digest/sha1'

  has_many  :order_items, :foreign_key => 'item_id', :conditions => "item_type = #{OrderItem::TypeAudio}"

  has_one :media_audio_property #use audio_properties method to access

  #class methods

  def self.get(id)
    #this depends on whether video approval is enabled
    if Configuration.queue_new_audios
      self.approved.find_by_id(id)
    else
      self.find_by_id(id)
    end
  end

  def self.supported_audio_type(uploaded_extension)
    Configuration.supported_audio_types.include?(uploaded_extension)
  end

  def self.save_and_queue_audio_job(uploaded_audio_file, user)
    if user.disk_space_used.to_i < user.host_plan.disk_space_bytes.to_i
      audio_file = AudioFile.new(uploaded_audio_file)
      if audio_file.size > 0
        #allowed audio type ?
        if Audio.supported_audio_type(audio_file.file_extension)
          Audio.transaction do
            begin
              audio = Audio.create(:title => audio_file.filename, :state => 1,
                :user_id => user.id, :orig_file_ext => audio_file.file_extension) #state 1 == 'uploaded to library'
              audio.copy_uploaded_audio_to_library(audio_file.file)
              #audio metadata
              audio.get_metadata_from_audio_file(audio_file)
              #set prices and licenses
              audio.license_id = user.default_upload_license
              audio.price      = Configuration.default_new_media_price
              #add to user
              user.audios << audio
              #schedule preview
              job = JobSpinner.spin_job do
                Job.enqueue_onto_queue!(:long, BackgroundWorker, :process_uploaded_audio, "Processs audio #{audio.title}", {:audio_id => audio.id})
              end  
              audio.job_id = job.id
              audio.state = 3
              audio.save!
              yield audio if block_given? #if we ever need to access generated audio
            rescue
              #something went wrong...clean up if necessary
              audio.delete_files unless audio.blank?
              #re-raise to propagate to controller
              raise
            end
          end
          status = 0
        else
          status = 1 #not supported audio type
        end
      else
        status = 10
        logger.fatal(['Uploaded audio file with size 0 in save_and_queue_video_job', audio_file.to_yaml].join("\n"))
        #TODO email admin
      end
    else
      status = 2
    end
    status
  end

  def self.queue_new_media
    Configuration.queue_new_audios
  end

  def self.recode_all_audio_for_user(user)
    user.audios.each do |audio|
      audio.convert_to_mp3
    end
  end

  #instance methods

  def copy_uploaded_audio_to_library(source_file)
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
    base_dir = File.expand_path("#{Rails.root}/images/audios/#{created_on.year.to_s}/#{created_on.month.to_s}/#{user_id}")
    if use_this_file_name.blank?
      File.join(base_dir, filename)
    else
      File.join(base_dir, use_this_file_name)
    end
  end

  def get_metadata_from_audio_file(audio_file)
    raise "Expected AudioFile but received #{audio_file.class.to_s}" unless audio_file.is_a? AudioFile
    self.duration     = audio_file.duration.to_i
    self.title        = File.basename(audio_file.filename, File.extname(audio_file.filename)) #remove extension
    self.file_size    = audio_file.size
    self.file_type    = audio_file.content_type
  end

  #override to delete audio files base method
  def delete_files
    unless filename.blank?
      File.delete(preview_file(:full_path => true)) if File.exists?(preview_file(:full_path => true))
      File.delete(original_file) if File.exists?(original_file)
    end
  end

  #partition mp3 audio preview file location by year/month and user. Throw in a hash in the path to prevent guessing for mp3 file locations
  def preview_file(options = {})
    base = "/library/audio/#{created_on.year.to_s}/#{created_on.month.to_s}/#{user_id}/#{id}u#{Digest::SHA1.hexdigest(created_on.to_s)}/#{id}.mp3"
    if options[:full_path].nil?
      base
    else
      File.join("#{Rails.root}/public/", base)
    end
  end

  def preview_file_dir
     File.dirname(preview_file(:full_path => true))
  end

  def convert_to_mp3
    #create flv  dir if it doesn't already exist
    FileUtils.mkdir_p(preview_file_dir) unless File.exist?(preview_file_dir)
    #
    the_file = preview_file(:full_path => true)
    #convert
    audio_file = MiniFfmpeg::Media.new(original_file)
    #options
    props = audio_properties(user)
    bitrate = props.bitrate
    length  = props.sample_length
    #
    if block_given?
      audio_file.convert_to_mp3(the_file, bitrate, length) {|progress| yield progress}
    else
      audio_file.convert_to_mp3(the_file, bitrate, length)
    end
  end

  def buy_description
    "Audio '#{description}'"
  end

  #TODO currentlt returns no_audio... add ability to add thumbnail to audio file
  def splash_file(options={})
    "/images/no_audio.png"
  end

  def thumbnail_file_public
    splash_file
  end

  def audio_properties(user = nil)
    unless media_audio_property.blank?
      properties = media_audio_property
    else
      properties = build_media_audio_property
      unless user.blank?
        properties.bitrate       = user.audio_preferences.bitrate
        properties.sample_length = user.audio_preferences.sample_length
      else
        properties.bitrate       = Configuration.preview_audio_bitrate
        properties.sample_length = Configuration.preview_audio_length
      end
    end
    properties
  end



end

class AudioFile < BaseUploadFile

  require 'mini_magick'

  attr_reader :width, :height, :duration, :type

  def initialize(file)
    super file
    #
    audio   = get_audio
    #
    @duration = audio.duration
    @type     = audio.type
  end

  protected

  def get_audio
    audio = MiniFfmpeg::Media.new(@file.local_path)
    audio.type = :audio
    audio
  end


end
