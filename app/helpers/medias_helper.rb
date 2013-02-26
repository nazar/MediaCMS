module MediasHelper

  def render_resolution_prices(prices, options={})
    options[:selected] ||= prices.first
    options[:class]    ||= 'options'
    markaby do
      for price in prices
        tr do
          td.check {radio_button_tag('price', price.id, price == options[:selected], :class => options[:class])}
          td "#{price.width} x #{price.height} px"
          td price.price, :align => 'right'
        end
      end
    end
  end

  def render_background_media_thumb
    raise "must supply block" unless block_given?
    markaby do
      div.image_thumbs_container do
        div :class => "image_thumbs clearfix" do
          yield
        end
      end
    end
    
  end

  def render_media_collection_thumbnails(media, options={})
    render_background_media_thumb do
      item_count = 0
      result = ''
      for collection in media.collections
        for item in collection.collections_items
          result << render_background_thumbnail_link(item.item)
          item_count += 1
          break if (options[:limit].to_i > 0) && (item_count > options[:limit].to_i-1)
        end
      end
      result
    end
  end

  def render_medias_as_thumbnails(medias, options={})
    render_background_media_thumb do
      item_count = 0
      result = ''
      for item in medias
        result << render_background_thumbnail_link(item)
        item_count += 1
        break if (options[:limit].to_i > 0) && (item_count > options[:limit].to_i-1)
      end
      result
    end
  end

  def media_info_row(title, data)
    markaby do
      tr do
        th title
        td.pad {data}
      end
    end
  end

  def media_price_options(media)
    options_by_id "media[#{media.id}][price]", { "Free" => "0", "One Credit" => "1" }, media.price.to_s
  end

  def media_price_edit_options(media)
    options_by_id "media[price]", { "Free" => "0", "One Credit" => "1" }, media.price.to_s
  end


  def media_to_path(action, media)
    eval("#{action.to_s}_#{media.class.name.downcase}_path(:id => #{media.id})")
  end

  def render_medias_block(medias, prefix = '')
    result = ''; audio = false;
    medias.each do |media|
      result << media_block(media, prefix, audio)
    end
    result << (render :partial => 'audios/hook_listener') if audio
    result
  end

  def media_block(media, prefix = '', audio = false)
    case media.class.to_s
      when 'Photo'
        photo_block(media)
      when 'Audio'
        audio = true; audio_block(media, prefix);
      when 'Video'
        video_block(media)
      else
        ''
    end
  end

  def render_background_thumbnail(media, options = {})
    src = media.thumbnail_file_public
    src = "#{current_domain}#{src}" if options.delete(:only_path) === false
    options.merge!({:class => 'crop_image_container'}) unless options.has_key?(:class)
    #
    if block_given?
      content = yield
    else
      content = '&nbsp;';
    end
    background = content_tag(:div, content, {:style => "background-image: url('#{src}');", :class => 'crop_image'})
    content_tag(:div, background, options)
  end

  def media_view_path(media)
    case media.class.name
      when "Photo"
        photo_view_link_path(media)
      when "Video"
        video_view_link_path(media)
      when "Audio"
        audio_view_link_path(media)
    end
  end

  def media_action_links(media, options={})
    actions = []
    #
    if options[:can_edit]
      actions << link_to('Edit', media_to_path(:edit, media))
      actions << link_to('Delete', media_to_path(:delete, media), :confirm => 'Delete this video?', :method => :post)
    end
    actions << link_to('Admin delete', {:action => :admin_delete_reason, :id => media.id}, {:id => 'admin_delete'}) if admin?
    actions << link_to('Un-approve', {:action => :unapprove, :id => media.id}, {:id => 'unapprove'}) if admin? && media.class.queue_new_media
    actions << link_to('Preview', {:action => 'preview', :id => media.id}, :popup => ['new_window', "height=315,width=315"]) if media.is_a? Photo
    if logged_in?
      actions << link_to_remote('Favourite', :url => {:action => 'favourite', :id => media.id}, :complete => 'alert("Added to favourites");')
      if (media.price.to_f == 0) || media.in_my_collection(current_user) || (media.user_id == current_user.id) || admin?
        actions << link_to('Download', {:action => :download, :id => media.id})
        actions << link_to('View original', {:action => :view_original, :id => media.id}) if media.is_a? Photo
      end
    else
      actions << link_to("login to #{media.price.to_i > 0 ? 'purchase' : 'download'}", :controller => 'account', :action => :login)
    end
    scripts = []
    scripts << javascript_tag("jQuery('a#admin_delete').attach(RemoteUpdateBlindShow, {update: '#extra'});") if admin?
    scripts << javascript_tag("jQuery('a#unapprove').attach(RemoteUpdateBlindShow, {update: '#extra'});") if admin? && media.class.queue_new_media
    #
    content_tag(:div,actions.join('&nbsp;|&nbsp;') + scripts.join(' '), :class => 'action_links')
  end

  def media_collections_title(collections)
    if collections.length > 1
      link = 'Collections ' <<
              collections.inject([]) do |links, collect|
                links << link_to(collections.index(collect)+1, collections_path(collect), :title => collect.name)
              end.join(', ') 
    else
      link = link_to 'Collection', collections_path(collections.first)
    end
    title = 'Similar Media by ' << link
    title
  end

  def media_rating_to_small_stars(media)
    if media.average_rating.to_i > 0
      stars = (1..media.average_rating.to_i).inject(''){|out, i| out << image_tag('rate-star.png')}
      content_tag(:span, stars + '&nbsp;' + media.ratings_count.to_i.to_s, :class => 'media_stats first-star')
    else
      ''
    end
  end

  def media_stats_block(media)
    content_tag(:div, :class => 'media_stats_wrapper') do
      media_rating_to_small_stars(media) <<
      content_tag(:span, image_tag('comment.png') + '&nbsp;' + media.comments_count.to_i.to_s, :class => 'media_stats') <<
      content_tag(:span, image_tag('view.png') + '&nbsp;' + media.views_count.to_i.to_s, :class => 'media_stats')
    end
  end

end