class LightboxesController < ApplicationController
  
  before_filter :login_required

  def download
    lightbox = Lightbox.find(params[:id])
    #photo = Photo.find(params[:id])
    #can only download if logged in and current user has bought this photo or library
    if current_user && (current_user.id == lightbox.user_id)
      if lightbox.link_type == 'Media'
        media = lightbox.link
        send_file media.original_file, :filename => media.media_title_for_download
        #record stats
        Lightbox.download_media_counters(lightbox)
      elsif lightbox.link_type == 'PhotoResolutionPrice'
        resized_file = Misc.resize_photo(lightbox.link)
        send_file resized_file, :filename => "#{lightbox.link.photo.title}_#{lightbox.link.width}x#{lightbox.link.height}.jpg"
        #record stats
        Lightbox.photo_resolution_download_stats
      end
    end 
  end
end