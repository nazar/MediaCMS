class AccountTabnav < Tabnav::Base    
       
    add_tab do 
      named 'About Me'
      links_to :controller => 'account', :action => 'index'
    end

    tab = add_tab do
      named 'Preferences'
    end
    add_submenu(tab) {submenu 'Audio Preferences', :links_to => {:controller => 'audios',  :action => 'preferences'}, :conditions => 'Configuration.module_audios'}
    add_submenu(tab) {submenu 'Notifications', :links_to => {:controller => 'notifications',  :action => 'my_notifications'}}

    tab = add_tab do
      named 'Upload'
    end
    add_submenu(tab) {submenu 'Photos',      :links_to => {:controller => 'photos',  :action => 'upload'}}
    add_submenu(tab) {submenu 'Videos',      :links_to => {:controller => 'videos',  :action => 'upload'}}
    add_submenu(tab) {submenu 'Audio Files', :links_to => {:controller => 'audios',  :action => 'upload'}}

    
    add_tab do
      named 'Collections'
      links_to :controller => 'collections', :action => 'my'
    end

    tab = add_tab do
      named 'My Library'
    end
    add_submenu(tab) {submenu 'Photo Library', :links_to => {:controller => 'photos', :action => 'library'}}
    add_submenu(tab) {submenu 'Video Library', :links_to => {:controller => 'videos', :action => 'library'}, :conditions => 'Configuration.module_videos'}
    add_submenu(tab) {submenu 'Audio Library', :links_to => {:controller => 'audios', :action => 'library'}, :conditions => 'Configuration.module_audios'}


    add_tab do
      named     'Licenses'
      links_to  :controller => 'licenses', :action => 'my'
      show_if   'current_user && (current_user.host_plan.own_license)'
    end


#    tab = add_tab do
#      named 'Articles'
#      show_if  'current_user && current_user.admin'
#    end
#
#    add_submenu(tab) {submenu 'My Articles', :links_to => {:controller => 'articles', :action => 'my_articles'}}
#    add_submenu(tab) {submenu 'Submit an Article', :links_to => {:controller => 'articles', :action => 'submit_article'}}
#    #add_submenu(tab) {submenu 'Bookmarked Articles', :links_to => {:controller => 'articles', :action => 'my_bookmarked'}}
#    add_submenu(tab) {submenu 'Article Administration', :links_to => {:controller => 'articles', :action => 'admin'},
#                                                     :conditions => 'current_user && (current_user.admin)' }
    
    add_tab do 
      named 'Accounting'
      links_to :controller => 'orders', :action => 'credit'
    end 

    add_tab do 
      named 'Hosting'
      links_to :controller => 'account', :action => 'account'
    end          
end