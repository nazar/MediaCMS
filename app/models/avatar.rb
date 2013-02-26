class Avatar < Picture

  def initialize(file, user)
    super(file)
    @user = user
  end
  
  def save
    if @file
      #using @id, find the id of the User, then use the id to create the title
      #max size 64x64 
      image = get_image
      if (image[:width] > 90) or (image[:width] > 90)
        @error = 'Avatar cannot be greater than 90x90 pixels'
        return false
      end
      
      if @content_type =~ /^image/
        #Make the directory for the id
        file = User.avatar_path(@user, true)
        dir  = File.dirname(file)
        Dir.mkdir(dir) unless File.exist?(dir)
        #Then create the temp file
        File.open(file, "wb") do |f|
          f.write(@file.read)
        return true
      end else
        @error = 'Only image files allowed!'
        return false
      end          
    end
  end
  
end