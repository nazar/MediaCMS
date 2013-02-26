module CategoriesHelper

  def render_category_breadcrumb(category)
    display_category_breadcrumb(category) {|n| link_to n.name, {:controller => 'category',
                                                            :action     => 'show',
                                                            :id         => n.id }}
  end  
  
  def display_category_breadcrumb(category)
    ret = ''
    if category.parent
      ret += display_category_breadcrumb(category.parent) { |n| yield n } 
      ret += ' > '
      ret += '<b>'
      ret += category.name
      ret += '</b>'
    else
      ret += yield category
    end
  end

  def render_category_links(categories, options={})
    options[:action] ||= 'show'
    links = []
    categories.each do |t|
      links << link_to(h(t.name),{ :controller => '/categories', :action => options[:action], :id => t.id, :name => t.name.to_permalink})
    end
    links.join(', ')
  end

  def categories_media_count_links(category, photos, videos, audios)
    links = []
    links << link_to(pluralize(category.photos.count, 'photo'), category_path(category)) unless photos.blank?
    links << link_to(pluralize(category.videos.count, 'video'), category_videos_path(category)) unless videos.blank?
    links << link_to(pluralize(category.audios.count, 'audio'), category_audios_path(category)) unless audios.blank?
    #
    if links.length > 1
      links.join(', ')
    elsif links.length == 1
      links.first
    else
      "no media"
    end
  end

  
end
