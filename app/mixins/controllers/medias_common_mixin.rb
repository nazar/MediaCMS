module MediasCommonMixin

  def download
    search_bot_allowed_here do
      media = Media.find(params[:id])
      #can download only if media is free or is in my collection
      if media.price.to_i > 0
        #check if i've bought this or in my collection
        if media.in_my_collection(current_user) || (current_user.id == media.user_id) || admin?
          send_media(media)
        else
          step_notice('Could not download media. Please <a href="/pages/contact_us">contact us</a> for further help.')
        end
      else
        send_media(media)
      end
    end
  end

  def send_media(media)
    send_file media.original_file, :filename => media.media_title_for_download
    #update count
    media.downloads += 1
    media.save
  end

  def unapprove
    @media = Media.find_by_id params[:id]
    valid_request_object_do(@media)
  end

  protected :send_media


end