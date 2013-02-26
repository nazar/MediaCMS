#TODO is this required? If not then delete
class MymenuTabnav < Tabnav::Base  
  
    tab = add_tab do
      named 'My Menu'
    end
    
    add_submenu(tab) {submenu 'My Control Panel',    :links_to => {:controller => '/account', :action => 'index'}} 
    add_submenu(tab) {submenu 'My Collection', :links_to => {:controller => '/collections', :action => 'my_collection'}} 
    add_submenu(tab) {submenu 'Upload Photos', :links_to => {:controller => '/account', :action => 'pictures'}} 
    add_submenu(tab) {submenu 'Write a New Blog', :links_to => {:controller => '/blogs', :action => :my_blog}} 
    add_submenu(tab) {submenu 'Logout',        :links_to => {:controller => '/account', :action => 'logout'}} 
    add_submenu(tab) {submenu 'Admin',         :links_to => {:controller => '/admin/dashboard', :action => 'index'},
                                               :conditions => 'admin?' }   
end