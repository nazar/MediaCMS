module ActionView::Helpers::AssetTagHelper
  
  #Renders a swatchables's colors. Accepts either a swatchable object or an array of hex colors
  #options- :swatch_class (defaults to .swatch) and :color_class (defaults to .swatch_color)
  def render_swatch(swatchable, options={}, &block)
    options[:swatch_class]         ||= 'swatch'
    options[:color_class]          ||= 'swatch_color'
    options[:color_class_selected] ||= 'swatch_color_selected'
    options[:container]            ||= :span
    options[:content]              ||= '&nbsp;'
    #
    members = swatchable.swatch_members.all :include => :swatch_color, :limit => options[:limit]
    result = ''
    unless members.blank?
      members.each do |member|
        color = member.swatch_color.to_hex
        #highlight selected color, if any
        if options[:selected_swatch_member_id].blank?
          color_class = options[:color_class]
        else
          color_class = options[:selected_swatch_member_id].to_i == member.id ? "#{options[:color_class]} #{options[:color_class_selected]}" : options[:color_class]
        end
        #render
        col_div = content_tag(options[:container], options[:content], :class => color_class, :style => "background-color:#{color}", :title => color)
        if block_given?
          capture{block.call(col_div, member)}
          concat(result, block.binding)
        else
          result << col_div
        end
      end
      result = content_tag(:div, result, :class => options[:swatch_class])
      concat(result, block.binding) if block_given?
    end
  end

end