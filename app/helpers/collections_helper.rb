module CollectionsHelper

  def price_to_desc(price)
    if price && (price > 0)
      pluralize(price,'Credits')
    else
      'Free'
    end
  end

  def collection_members(collection)
    result = ''
    collection.each do |collection_item|
      result << render_background_thumbnail(collection_item.item) do
        link_to(image_tag('view.png'), media_view_path(collection_item.item),
                 :title => collection_item.item.title, :class => 'photo_link collection_view') <<
        check_box_tag("in_#{collection_item.id}", "1", false, :name => "item[#{collection_item.id}]", :class => 'in_collection')
      end
    end
    result
  end

  #render medias except for media items in collection
  def media_for_collection(medias)
    result = ''
    medias.each do |media|
      result << render_background_thumbnail(media) do
        link_to(image_tag('view.png'), media_view_path(media),
                 :title => media.title, :class => 'photo_link collection_view') <<
        check_box_tag("out_#{media.id}", "1", false, :name => "media[#{media.id}]", :class => 'out_collection')
      end
    end
    result
  end

  def collection_action_links(collection)
    actions = []
    unless current_user.blank?
      if collection.price.to_f > 0
        if collection.in_my_library(current_user)
          actions << link_to('Download collection', collections_download_path(collection))
        else
          actions << link_to_remote('Add to Cart', :url => {:controller => 'orders', :action => :add_collection_to_cart, :id => collection.id}) 
        end
      else
        actions << link_to('Download collection', collections_download_path(collection))
      end
      actions << link_to('Edit', collections_edit_path(collection)) if collection.user_id == current_user.id
    else
      actions << ( @collection.price.to_f > 0 ?  "Please login or register to purchase and download" : "Please login or register to download") 
    end
    actions.join(' | ')
  end
  
end
