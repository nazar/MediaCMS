module ClubsHelper
  
   def extra_buttons(id, object)
     if id == 1
       link_to_remote image_tag('email.gif'),    
                              {:url => {:action => 'resend_news_item', :id => object.id}, 
                              :confirm => "Are you sure you want to email #{object.title} to all club members?"},
                              {:class => 'no_underline', :title => 'Resend Newsletter to all Club members'}
     end                              
   end
   
  def render_club_tag_cloud(tag, min_count, max_count)
    #determine font size
    size = tag_font_size(tag, max_count, min_count)
    link_to tag.name, {:controller => 'tags', :action => :show_clubs, :id => tag.name.gsub('.','^^')},
                      {:style => "font-size:#{size.to_i}px", 
                       :title => pluralize(tag.taggings_count,'photo') } 
  end

  def club_admin_links(club)
    actions = []
    if club.is_club_admin(current_user) || admin?
      actions << link_to('Club News', club_news_admin_path(club))
      actions << link_to('Club Forums', club_forum_admin_path(club))
      actions << link_to('View Membership Applications', club_applications_path(club)) unless club.free
    end
    actions.join('&nbsp;|&nbsp;')
  end
   
end

