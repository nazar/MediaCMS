#TODO is this required... if not then delete
class FrontpageTabnav < Tabnav::Base    
   add_tab do 
      named 'Login'
      show_if  '!logged_in?'
      links_to :controller => '/account', :action => 'login'
    end
    
    add_tab do 
      named 'Register'
      show_if  '!logged_in?'
      links_to :controller => '/account', :action => 'signup'
    end              
end