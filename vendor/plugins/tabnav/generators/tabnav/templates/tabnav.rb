class <%=tabnav_name.camelize%>Tabnav < Tabnav::Base    
       
    add_tab do 
      named 'Dashboard'
      links_to :controller => 'dashboard'
    end
    
    add_tab do 
      named 'Users'
      links_to :controller => 'users'
    end 
         
end