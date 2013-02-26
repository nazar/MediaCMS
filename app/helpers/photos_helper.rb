module PhotosHelper

  def render_photo(data_url)
    render :partial => '/maps/map_editor', :locals => {:data_url => data_url}
  end
  
  def render_most_viewed
    photos = Photo.most_popular(:limit => Configuration.photos_in_block*2);
    photos = random_select(photos, Configuration.photos_in_block)
    render_photo_block(photos)
  end

  def render_most_talked_about
    photos = Photo.most_talked(:limit => Configuration.photos_in_block);
    render_photo_block(photos)
  end

  def render_most_favourites
    photos = Photo.most_favourited(:limit => Configuration.photos_in_block);
    render_photo_block(photos)
  end

  def render_best_selling
    photos = Photo.best_selling(:limit => Configuration.photos_in_block);
    render_photo_block(photos)
  end

  def render_most_voted
    photos = Photo.most_voted(:limit => Configuration.photos_in_block);
    render_photo_block(photos)
  end

  def render_top_five_photos
    #get double the photos and randomly show half of them
    photos = Photo.latest_top_rated(Configuration.photos_in_block*2);
    photos = random_select(photos, Configuration.photos_in_block)
    render_photo_block(photos)
  end

  def render_last_five_photos
    photos = Photo.most_recent(:limit => Configuration.photos_in_block*2);
    photos = random_select(photos, Configuration.photos_in_block)
    render_photo_block(photos)
  end

  def photo_block(photo)
    content_tag(:div, :class => 'listPhotos') do
      render :partial => '/photos/small_picture', :locals => {:photo => photo}
    end
  end

  def render_photo_block(photos)
    body = ''
    unless photos.blank?
      for photo in photos do
        body << photo_block(photo) if photo
      end
      body
    end
  end

  def render_background_thumbnail_link(photo, options={}, html_options={})
    render_background_thumbnail(photo, options) do
      link_to(content_tag(:span, '&nbsp;', :class => 'crop_image_link'), photo_view_path(photo.id, photo.title.to_permalink), {:title => photo.title, :class => 'photo_link'}.merge(html_options))
    end
  end

  def thumbnail_path(photo, options = {})
    if options.delete(:only_path) === false
      "#{current_domain}#{photo.thumbnail_file_public}"
    else
      photo.thumbnail_file_public
    end
  end

  def renderThumbnail(photo, options = {})
    unless photo.blank?
      image_tag(thumbnail_path(photo, options), {:alt => photo.safe_title}.merge(options))
    end
  end

  def render_view(photo, options = {})
    if scale = options.delete(:scale)
      options[:width]  = (photo.preview_width.to_f  * scale.to_f).to_i
      options[:height] = (photo.preview_height.to_f * scale.to_f).to_i
    end
    image_tag(photo.preview_file(false), {:alt => photo.title}.merge(options))
  end

  def render_full_image(photo)
    send_file photo.original_file, :type => 'image/jpeg', :disposition => 'inline'
  end

  def renderViewFullPath(photo)
    image_tag("#{current_domain}#{photo.preview_file(false)}", {:alt => photo.title})
  end

  def renderPreview(photo)
    image_tag(photo.crop_file(false),{:alt => photo.title})
  end

  def photo_popup(photo)
    width = (photo.preview_width.to_i * Configuration.photos_popup_resize_ratio).to_i
    markaby do
      div :style => "width:#{width}px" do
        render_view(photo, :width => width, :height => (photo.preview_height.to_i * Configuration.photos_popup_resize_ratio).to_i)
        div {strong photo.title}
        div {photo.formatted_description unless photo.description.blank? || (photo.description && (photo.description == photo.title))}
        div {media_stats_block(photo)}
      end
    end
  end


end
