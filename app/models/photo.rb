#photo_state
#------------
# 0 - Created
# 1 - Uploaded
# 2 - Copied to Libary
# 3 - Post Upload Processing Job Created
# 10- converted

class Photo < Media

  acts_as_swatchable :file => 'thumbnail_file'

  has_many  :order_items, :foreign_key => 'item_id', :conditions => 'item_type = 1'
  has_many  :photo_resolution_prices, :order => 'price ASC'

  #class methods

  def self.get(id)
    #this depends on whether photo_approval is enabled
    if Configuration.queue_new_photos
      self.approved.find_by_id(id)
    else
      self.find_by_id(id)
    end
  end

  def self.delete_license_update(license, user)
    #find all photos for this user and license then update to standard license
    Photo.update_all(["license_id = ?",Configuration.standard_license],
                     ["user_id = ? and license_id = ?",user.id, license.id])
  end

  def self.supported_image_type(uploaded_extension)
    Configuration.supported_image_types.include?(uploaded_extension)
  end

  def self.create_preview_and_thumbnail_files_by_id(id)
    photo = Photo.find_by_id id
    photo.create_preview_and_thumbnail_files
    photo.state = 10
    photo.save!
  end

  #called by #AccountController.uploadPhoto to save uploaded file and queue a photo processing job
  def self.save_and_queue_photo_job(uploaded_photo_file, user)
    if user.disk_space_used.to_i < user.host_plan.disk_space_bytes.to_i
      picture = Picture.new(uploaded_photo_file)
      if picture.size > 0
        #allowed image type
        if Photo.supported_image_type(picture.file_extension)
          Photo.transaction do
            begin
              photo = Photo.create(:title => picture.filename, :state => 1,
                :user_id => user.id, :orig_file_ext => picture.file_extension) #state 1 == 'uploaded to library'
              photo.copy_uploaded_image_to_library(picture.file)
              #photo metadata
              photo.get_metadata_from_picture(picture)
              #set prices and licenses
              photo.license_id   = user.default_upload_license
              #determine whether setting price manually or by photo size
              if Configuration.multiple_resolution_prices
                photo.price = PhotoResolutionPriceDefault.get_resolution_based_price_by_area(photo.width * photo.height)
              else
                photo.price = Configuration.default_new_media_price
              end
              #add to user
              user.photos << photo
              #schedule preview and thumbnail
              job = JobSpinner.spin_job do
                Job.enqueue_onto_queue!(:short, BackgroundWorker, :process_uploaded_photo, "Process photo #{photo.title}", {:photo_id => photo.id})
              end  
              photo.job_id = job.id
              photo.state = 3
              photo.save!
            rescue
              #something went wrong...clean up if necessary
              photo.delete_files unless photo.blank?
              #re-raise to propagate to controller
              raise
            end
          end
          #
          status = 0
        else
          status = 1 #not supported image type
        end
      else
        status = 10
        logger.fatal(['Uploaded picture file with size 0 in save_and_queue_photo_job', picture.to_yaml].join("\n"))
        #TODO email admin
      end
    else
      status = 2
    end
    #
    status
  end

  def self.queue_new_media
    Configuration.queue_new_photos
  end

  #override media lightboxes as a photo is either #media or #PhotoResolutionPrice
  def self.lightboxes
    scope = super.scope(:find)
    scope[:conditions] = Lightbox.types_of_photo.scope(:find)[:conditions]
    Lightbox.scoped(scope)
  end

  #instance methods

  def delete_files
    if filename
      File.delete(thumbnail_file) if File.exists?(thumbnail_file)
      File.delete(crop_file)      if File.exists?(crop_file)
      File.delete(preview_file)   if File.exists?(preview_file)
      File.delete(original_file)  if File.exists?(original_file)
    end
  end

  def exif_hash
    ex = self.exif.split("\n")
    if ex.length > 0
      ex_hash = Hash.new
      ex.each do |e|
        exi = e.split('=')
        if exi.length == 2
          ex_hash[exi[0]] = exi[1]
        end
      end
    else
      ex_hash = false
    end
    ex_hash
  end

  def photo_caption
    "title: #{self.title}, description: #{self.description}"
  end

  def original_file(use_this_file_name = nil)
    base_dir = File.expand_path("#{Rails.root}/images/photos/#{created_on.year.to_s}/#{created_on.month.to_s}/#{user_id}")
    if use_this_file_name.blank?
      File.join(base_dir, filename)
    else
      File.join(base_dir, use_this_file_name)
    end
  end

  def preview_file(full_path = true)
    base = "/library/view/#{user_id}/#{id}.jpg"
    if full_path
      File.join(Rails.root, 'public',base)
    else
      base
    end
  end

  def thumbnail_file(full_path = true)
    file = "/library/thumb/#{user_id}/#{id}.jpg"
    if full_path
      File.join(Rails.root, 'public', file )
    else
      file
    end
  end

  def thumbnail_file_public
    thumbnail_file(false)
  end

  def crop_file(full_path = true)
    base = "/library/preview/#{user_id}/#{id}.jpg"
    if full_path
      File.join(Rails.root, 'public',base)
    else
      base
    end
  end

  def preview_file_dir
    File.expand_path(File.dirname(preview_file))
  end

  def thumbnail_file_dir
    File.expand_path(File.dirname(thumbnail_file))
  end

  def crop_file_dir
    File.expand_path(File.dirname(crop_file))
  end

  def original_file_dir
    File.expand_path(File.dirname(original_file))
  end

  def copy_uploaded_image_to_library(source_file)
    self.filename = "#{id}#{orig_file_ext}"
    store_file    = original_file(filename)
    #create dir if it doesn't already exist
    FileUtils.mkdir_p(File.dirname(store_file)) unless File.exist?(File.dirname(store_file))
    #copy uploaded tmp file to library
    File.open(store_file, "wb") do |f|
      f.write(source_file.read)
    end
  end

  def create_preview_and_thumbnail_files
    #crop the image from the original first
    crop_original_image_for_preview
    #load original again but re-use the image to create a preview then optimise by thumbnailing the preview instead of the original
    orig_image = MiniMagick::Image.from_file(original_file)
    preview = create_preview_file(orig_image)
    #create thumbnail from un-altered preview
    create_thumbnail_file(preview)
    #if swatches enabled then create swatch for image
    swatch_from_image if Configuration.color_analysis_module
    #
    watermark_preview_file(preview_file) if Configuration.images_watermark
    annotate_preview_file(preview_file) if Configuration.images_annotate
  end

  #create unwatermarked preview file. Will create preview dir if missing
  #can be passed an Image. Otherwise, a new Image is created based on the uploaded file
  def create_preview_file(image = nil)
    if image.nil?
      medium_image = MiniMagick::Image.from_file(original_file)
    else
      medium_image = image.dup
    end
    Dir.mkdir(preview_file_dir) unless File.exist?(preview_file_dir)
    #
    medium_image.combine_options do |c|
      c.resize "#{Configuration.medium_width}x#{Configuration.medium_height}"
      c.strip
    end
    medium_image.write(preview_file)
    query_preview_dimensions(medium_image)
    #
    medium_image
  end

  def query_preview_dimensions(image = nil)
    if image.nil?
      if File.exist?(preview_file)
        medium_image = MiniMagick::Image.from_file(preview_file)
      else
        return
      end
    else
      medium_image = image.dup
    end
    #save width and height for preview popups
    self.preview_width  = medium_image[:width]
    self.preview_height = medium_image[:height]
  end

  #Create thumbnail file. Will create thumbnail dir if missing
  #Can be passed an Image or an image file name. Otherwise, a new Image is created based on the uploaded file
  def create_thumbnail_file(image = nil)
    if image.nil?
      small_image = MiniMagick::Image.from_file(original_file)
    elsif image.is_a? MiniMagick::Image
      small_image = image.dup
    elsif image.is_a? String
      small_image = MiniMagick::Image.from_file(image)
    else
      raise "Invalid image parameter. Expected either nil, Image or String but got #{image.class.to_s}"
    end
    Dir.mkdir(thumbnail_file_dir) unless File.exist?(thumbnail_file_dir)
    #
    small_image.thumbnail "#{Configuration.thumbnail_width}x#{Configuration.thumbnail_height}>"
    small_image.write(thumbnail_file)
    #
    small_image
  end

  def crop_original_image_for_preview(image = nil)
    if image.nil?
      crop_image = MiniMagick::Image.from_file(original_file)
    elsif image.is_a? MiniMagick::Image
      crop_image = image.dup
    end
    #resize only if larger than preview size
    if (crop_image[:width].to_i * crop_image[:height].to_i) > 90000
      crop_image.combine_options do |c|
        c.crop "300x300 +0 +0"
        c.strip
      end
    end
    Dir.mkdir(crop_file_dir) unless File.exist?(crop_file_dir)
    crop_image.format('jpg') unless ['.jpeg','.jpg'].include?(File.extname(original_file))
    crop_image.write(crop_file)
    #
    crop_image
  end

  #Annotate the preview image file.
  #Accepts either an Image. If nil then an Image will be created based on the original file, resized then annotated
  def annotate_preview_file(image = nil) 
    if image.nil?
      annotate_image = create_preview_file
    elsif image.is_a? MiniMagick::Image
      annotate_image = image.dup
    elsif image.is_a? String
      annotate_image = MiniMagick::Image.from_file(image)
    else
      raise "Invalid argument"
    end
    #annotate_image.annotate(Configuration.image_watermark_text, preview_file, 32, '0x0+10+50' ) unless Configuration.image_watermark_text.blank?
    annotate = 'copyright ' + user.pretty_name + " - #{Configuration.domain_of_site} id: "+ id.to_s
    annotate_image.annotate_box(annotate, preview_file ) 
    annotate_image #return
  end

  #draw a cross on the preview image file.
  #Accepts either an Image. If nil then an Image will be created based on the original file, resized then annotated
  def watermark_preview_file(image = nil)
    if image.nil?
      annotate_image = create_preview_file
    elsif image.is_a? MiniMagick::Image
      annotate_image = image.dup
    elsif image.is_a? String
      annotate_image = MiniMagick::Image.from_file(image)
    else
      raise "Invalid argument"
    end
    annotate_image.watermark_cross(preview_width, preview_height, preview_file )
    annotate_image #return
  end


  def resize_photo_to_resolution_to_file(resolution, save_name)
    mm_photo = MiniMagick::Image.from_file(self.original_file)
    mm_photo.combine_options do |c|
      c.resize resolution
    end
    mm_photo.write(save_name)
  end

  def get_metadata_from_picture(picture)
    raise "Expect Image but received #{picture.class.to_s}" unless picture.is_a? Picture
    self.width        = picture.width
    self.height       = picture.height
    self.aspect_ratio = (self.width.to_f / self.height.to_f).to_f if self.height > 0
    self.exif         = picture.exif
    self.title        = File.basename(picture.filename, File.extname(picture.filename)) #remove extension
    self.file_size    = picture.size
    self.file_type    = picture.content_type
  end

  def post_rating_processing(rating)
    user.ratings += rating.rating
    if user.ratings_count > 0
      user.ratings_count += 1
    else
      user.ratings_count = 1
    end
    user.save
  end

  def native_browser_support
    #browsers only support some images to display inline...ie tiff cannot be displayed by a web browser
    if ext = media_extension
      ['jpg', 'jpeg', 'gif', 'png'].include?(ext)
    else
      false
    end  
  end

  #options: :limit, :depth and :colorscon
  def top_colors(options = {})
    options = {:limit => Setup.color_analysis_limit, 
               :depth => Setup.color_analysis_bits,
               :colors => Setup.color_analysis_colors}.merge(options)
    if File.exists?(thumbnail_file)
      i = MiniMagick::Image.new(thumbnail_file)
      i.top_colors(options[:limit], options[:depth], options[:colors])
    else
      []
    end
  end

  def buy_description
    "Photo '#{title}'"
  end

  def is_one_of_my_resolutions(resolution)
    raise "Expected PhotoResolutionPrice but got #{resolution.class.to_s}" unless resolution.is_a? PhotoResolutionPrice
    resolution.photo_id == id
  end

end
