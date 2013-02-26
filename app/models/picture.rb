require 'mini_magick'

class Picture < BaseUploadFile

  attr_reader :width, :height, :exif

  def initialize(file)
    super file
    #get width, height and exif
    image   = get_image
    #
    @width  = image[:width]
    @height = image[:height]
    @exif   = image['EXIF:*']
  end

  protected

  def get_image
    if file.is_a?(StringIO)
      MiniMagick::Image.from_blob(@file.string)
    else
      MiniMagick::Image.from_file(@file.local_path)
    end
  end


end
