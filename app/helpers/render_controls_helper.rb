module RenderControlsHelper

  def render_category_select(object, select_options, options={})
    raise "DOM id is missing" if options[:id].blank?
    options[:size]    ||= 5
    options[:multiple] ||= 'multiple'
    options[:name]    ||= "categories[#{object.id}][]"
    options.merge!({:style => 'border:red 4px solid;'}) if object.errors && (object.errors.length > 0) && object.errors['categories']
    #
    label = content_tag(:label, 'Categories', :for => options[:id]) << '<br />'
    select = content_tag(:select, select_options, options)
    label << select
  end

  def render_media_title(media, options={})
    options[:size] ||= 30
    options[:name] ||= "#{media.class.name.downcase}[#{media.id}][title]"
    options[:id]   ||= "audio_title_#{media.id}"
    #error highlight bit
    options.merge!({:style => 'border:red 4px solid;'}) if media.errors && (media.errors.length > 0) && media.errors['title']
    #out with it
    text_field_tag options[:name], media.title, :id => options[:id], :size => options[:size], :style => options[:style]
  end
    
end
