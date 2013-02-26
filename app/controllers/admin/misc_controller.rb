class Admin::MiscController < Admin::BaseController
 
  #recalculates all user's photo and disk_space used count 
  def sync_users
    User.transaction do
      #TODO refactor into model
      user = User.new
      sql = "update users set photos_count    = (select count(id) from medias where medias.user_id = users.id)"
      user.connection.update(sql)
      sql = "update users set disk_space_used = (select sum(file_size) from medias where medias.user_id = users.id)"
      user.connection.update(sql)
    end
    render :action => :index
  end
	
	def sync_licenses
    #iterate through all photos and populate this table if a user has multiple licenses
    Photo.transaction do    #TODO update photo to Media
      Photo.categorised.approved.each{|photo|
        MediaLicensePrice.setup_media_licenses_for_media_and_user(photo)
      }
    end
  end


end
