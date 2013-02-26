module TagsHelper

  def tag_font_size(tag, max_count, min_count = 0)
    base_size = 11
    if max_count > min_count
      return (base_size + 13 * ((tag.taggings_count - min_count).to_f/(max_count - min_count).to_f)).to_i
    else
      return base_size
    end
  end
  
  def render_article_tag_cloud(tag, min_count, max_count)
    #determine font size
    size = tag_font_size(tag, max_count, min_count)
    link_to tag.name, {:controller => 'tags', :action => :articles, :id => tag.name.gsub('.','^^')},
                      {:style => "font-size:#{size.to_i}px", 
                       :title => pluralize(tag.taggings_count,'article') } 
  end

  def render_my_tag_cloud(tag, user, max_count)
    #determine font size
    size = tag_font_size(tag, max_count)
    link_to tag.name, {:controller => 'tags', :action => :my_tags, :id => tag.name, :user => user.login},
                      {:style => "font-size:#{size.to_i}px", 
                       :title => pluralize(tag.taggings_count,'photo') } 
  end

end
