module Admin::ServerTaskLogsHelper

  #show first line in list view
  def log_column(record)
    lines = record.log.split("\n")
    if lines && lines.length > 1
      show_first_line_with_expand(record, lines)
    else
      record.log
    end
  end
  
  #show first line and hide rest and show with on on click
  def show_first_line_with_expand(record, lines)
    on_show_click = "Element.toggle('first_log_#{record.id}'); Element.toggle('rest_log_#{record.id}'); return false;"
    #
    first_line = link_to(lines[0], {:action => :show_log_detail, :id => record.id}, {:onclick => on_show_click})
    first_line = content_tag(:div,first_line,:id => "first_log_#{record.id}")
    hidden = content_tag(:div, lines[0..lines.length-1], :id => "rest_log_#{record.id}", 
                         :style => 'display: none', :class => 'small', :onclick => on_show_click)
    #                 
    first_line + hidden
  end
    
end
