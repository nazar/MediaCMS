class SampleTabnav < Tabnav::Base

  add_tab do 
    named 'Tab One'
    links_to :action => 'prova'
    highlights_on  :action => 'prova'
    highlights_on  :controller => 'pippo', :action => 'prova2'
  end
 
end