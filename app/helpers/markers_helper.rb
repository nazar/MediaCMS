module MarkersHelper

  def draw_map(obj, options)
    width = options.delete(:width); width ||= '100%'
    height = options.delete(:height); height ||= '100%'
  end

end
