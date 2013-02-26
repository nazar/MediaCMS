module MapsHelper

  def markers_to_markup(markers)
    if markers.length > 0
      out = [] 
      markers.each{ |m|
        out << "#{m.lat}^#{m.long}^#{m.title.gsub('^',' ')}^#{m.markable_id}"
      }
      return out.join(';')
    else
      return '-1'
    end
  end

  
end