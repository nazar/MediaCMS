  # renders the tabnav
module ApplicationHelper  

  def tabnav tabnav_sym, options = {}
    target = options[:target] ? "tabnav/#{options[:target]}_tabnav" : "tabnav/#{tabnav_sym.id2name}_tabnav"
    result = capture do
      render  :partial => target, 
              :locals => { :tabs => tabnav_sym.to_tabnav.tabs }
    end
    result  
  end
  
  # adds the content div
  def start_tabnav tabnav_sym, options = {}
    result = tabnav(tabnav_sym, options) 
    result << "\n"
    result << "<div id='#{tabnav_sym.id2name}_content'>"
    result 
  end
  
  def end_tabnav
    "</div>"
  end
  
end
