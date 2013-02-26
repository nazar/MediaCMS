require 'cgi'

class BaseUploadFile
  
  attr_accessor :file, :filename, :content_type, :size, :file_extension
  
  def initialize(file)
    @file = file
    if @file.is_a?(StringIO)
      @filename     = @file.original_filename
    else
      @filename     = @file.original_filename()
    end
    #
    @size           = @file.size
    @content_type   = @file.content_type.blank? ? '' : @file.content_type.chomp
    @file_extension = File.extname(@filename).downcase
  end
    
end