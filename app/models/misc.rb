require 'redcloth'
#require 'zip/zip'
#require 'zip/zipfilesystem'
require 'fileutils'

class Misc #TODO move to lib instead of model

  def Misc.format_red_cloth(text)
    if text && (text.length > 0)
      rc = RedCloth.new(text)
      rc.to_html
    end
  end

  def Misc.un_red_cloth(markup)
    red = Misc.format_red_cloth(markup)
    #now remove HTML encoding
    strip_tags(red)
  end

  def Misc.resize_photo(resolution) #TODO move to resolution model
    photo = resolution.photo
    file_name = "#{RAILS_ROOT}/tmp/resize_cache/#{photo.id}_#{photo.title.to_permalink}_#{resolution.id}.jpg"
    #if file previously created then send back
    unless File.exists?(file_name)
      #check if resize cache exists
      unless File.exists?(File.dirname(file_name))
        FileUtils.mkdir File.dirname(file_name)
      end
      resolution.photo.resize_photo_to_resolution_to_file("#{resolution.width}x#{resolution.height}", file_name)
    end
    file_name
  end

end
