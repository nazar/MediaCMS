#TODO delete as no longer needed
class FrontpageleftTabnav < Tabnav::Base    
  tab = add_tab do 
    named 'Home'
    links_to :controller => '/TopPage', :action => 'index'
  end
#  add_submenu(tab) {submenu 'Top Photos',    :links_to => {:controller => 'photos', :action => 'top_photos'}} 
  add_submenu(tab) {submenu 'New Photos', :links_to => '/#recent_photo_link'  }
  add_submenu(tab) {submenu 'New Collections', :links_to => '/#recent_collection_link'  }
  add_submenu(tab) {submenu 'New Links', :links_to => '/#latest_links_link'  }
  add_submenu(tab) {submenu 'New Blogs', :links_to => '/#latest_blog_link'  }
  add_submenu(tab) {submenu 'New Topics', :links_to => '/#recent_topics_link'  }
  add_submenu(tab) {submenu 'New Comments', :links_to => '/#recent_comments_link'  }

#TODO disable for the time being... enable later
#  add_tab do 
#    named 'Photographers'
#    links_to :controller => '/account', :action => 'photographers'
#  end

  tab = add_tab do 
    named 'Photos'
    links_to :controller => '/photos', :action => 'more_photos'
  end
  add_submenu(tab) {submenu 'Upload Photo', :links_to => {:controller => 'account', :action => 'pictures'} } 
  add_submenu(tab) {submenu 'Photos on Google Maps', :links_to => {:controller => 'maps', :action => 'index'} } 
  add_submenu(tab) {submenu 'Photo Tags', :links_to => {:controller => 'tags', :action => 'index'}} 
  add_submenu(tab) {submenu 'My Photos', :links_to => {:controller => 'account', :action => 'mypictures'} } 
  add_submenu(tab) {submenu 'My Library', :links_to => {:controller => 'account', :action => 'library'} } 
  add_submenu(tab) {submenu 'My Favourites', :links_to => {:controller => 'account', :action => 'favourites'} } 
  add_submenu(tab) {submenu 'My Licenses', :links_to => {:controller => 'licenses', :action => 'my'} } 

  tab = add_tab do 
    named 'Blogs'
    links_to :controller => '/blogs', :action => 'index'
    show_if 'Configuration.module_blogs'
  end
  add_submenu(tab) {submenu 'Create a Blog', :links_to => {:controller => 'blogs', :action => 'my_blog'}} 
#  add_submenu(tab) {submenu 'Most Viewed', :links_to => {:controller => 'blogs', :action => 'my_blog'}} 
#  add_submenu(tab) {submenu 'Most Read', :links_to => {:controller => 'blogs', :action => 'my_blog'}} 

#  tab = add_tab do 
#    named 'Articles'
#    links_to :controller => '/articles', :action => 'index'
#  end
#  add_submenu(tab) {submenu 'Submit an Article', {:links_to => {:controller => 'articles', :action => 'submit_article'}},
#                    {:conditions => 'current_user && current_user.admin?'}  } 
##  add_submenu(tab) {submenu 'Article Tags', :links_to => {:controller => 'tags', :action => 'article_tags'}} 
#  add_submenu(tab) {submenu 'Article Adminstration', {:links_to => {:controller => 'articles', :action => 'admin'} }, 
#                                                     {:conditions => 'current_user && current_user.admin?'}} 

  tab = add_tab do 
    named 'News'
    links_to :controller => '/news', :action => 'index'
  end
  add_submenu(tab) {submenu 'Syndicated News', :links_to => '/news/#syndicated'} 
  
  tab = add_tab do 
    named 'Forums'
    links_to :controller => '/forums', :action => 'index'
    show_if 'Configuration.module_forums'
  end
  add_submenu(tab) {submenu 'Support Forum', :links_to => {:controller => 'forums', :action => 'show', :id => 1} } 
#  add_submenu(tab) {submenu 'Latest Topics', :links_to => '/forum/1'} 
#  add_submenu(tab) {submenu 'Hot Topics', :links_to => '/forums/1'} 

  tab = add_tab do 
    named 'Photography Links'
    links_to :controller => '/links', :action => 'index'
    show_if 'Configuration.module_links'
  end
  add_submenu(tab) {submenu 'Submit a Link',    :links_to => {:controller => 'links', :action => 'add_link'} } 
  add_submenu(tab) {submenu 'Popular Links',    :links_to => {:controller => 'links', :action => 'index'} } 
  add_submenu(tab) {submenu 'Today\'s Links',     :links_to => {:controller => 'links', :action => 'today'} } 
  add_submenu(tab) {submenu 'This Week\'s Links',  :links_to => {:controller => 'links', :action => 'week'} } 
  add_submenu(tab) {submenu 'This Month\'s Links', :links_to => {:controller => 'links', :action => 'month'} } 
  add_submenu(tab) {submenu 'My Links',         :links_to => {:controller => 'links', :action => 'my_links'} } 
  add_submenu(tab) {submenu 'My Saved Links',   :links_to => {:controller => 'links', :action => 'my_favourites'} } 
  
  tab = add_tab do 
    named 'Clubs'
    links_to :controller => '/clubs', :action => 'index'
  end
  add_submenu(tab) {submenu 'Create A Club', :links_to => {:controller => 'clubs', :action => 'my_clubs'} } 
  
  tab = add_tab do 
    named 'Collections'
    links_to :controller => '/collections', :action => 'index'
  end
  add_submenu(tab) {submenu 'Create A Collection', :links_to => {:controller => 'collections', :action => 'my_collection'} } 
  
  tab = add_tab do 
    named 'My Account'
    links_to :controller => '/account'
  end
  add_submenu(tab) {submenu 'My Profile', :links_to => {:controller => 'account', :action => 'index'} } 
  add_submenu(tab) {submenu 'My Blogs', :links_to => {:controller => 'blogs', :action => 'my_blog'} } 
  add_submenu(tab) {submenu 'My Notifications', :links_to => {:controller => 'notifications', :action => 'my_notifications'} } 
  add_submenu(tab) {submenu 'My Clubs', :links_to => {:controller => 'clubs', :action => 'my_clubs'} } 
  add_submenu(tab) {submenu 'Accounting & Sales Hisory', :links_to => {:controller => 'orders', :action => 'credit'} }  
  add_submenu(tab) {submenu 'Hosting Plans', :links_to => {:controller => 'account', :action => 'account'} } 

  tab = add_tab do 
    named 'Login'
    links_to :controller => '/account', :action => 'login'
    show_if 'not current_user'
  end
  add_submenu(tab) {submenu 'Register', {:links_to => {:controller => 'account', :action => 'signup'} }, {:conditions => 'not current_user'}} 
  add_submenu(tab) {submenu 'Login', {:links_to => {:controller => 'account', :action => 'login'} }, {:conditions => 'not current_user'}} 

  tab = add_tab do 
    named 'Logout'
    links_to :controller => '/account', :action => 'logout'
    show_if 'current_user'
  end


  tab = add_tab do 
    named 'Administration'
    links_to :controller => '/admin', :action => 'dashboard'
    show_if 'current_user && current_user.admin?'
  end
  add_submenu(tab) {submenu 'Dashboard', {:links_to => {:controller => '/admint', :action => 'dashboard'} }} 
  
  
end
