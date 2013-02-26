module MarkupHelper

  protected

  #always call markup_area or markup_editor_tag
  def markup_area(name, method, options = {}, html_options = {})
    options[:delayed_load] = options[:delayed_load] === false ? false : true #defaults to true
    #
    idobj  = eval("@#{name}.id")
    id     = idobj.blank? ? '' : "_#{idobj}"
    area   = "#{name}_#{method}#{id}"
    result = markup_editor_area(name, method, options.merge({:id => id}), html_options.merge({:id => area}))
    #
    toolbar = wikitoolbar_for(area)
    if html_options[:delayed_load]
      add_footer_sript(toolbar)
    else
      result << javascript_tag("function loadToolbar() {toolbar = new jsToolBar($('#{area}')); toolbar.draw();} loadToolbar(); ")
    end
    #behaviour js
    link = "#{method_to_preview_dom(name, method, id)}_link"
    result << javascript_tag do
      "jQuery('a##{link}').show();" <<
      "jQuery('a##{area}_preview_link').attach(MarkupAreaSlidePreview, {control: '##{area}'});" <<
      "jQuery('a##{area}_preview_close').attach(MarkupAreaSlideCloseClearPreview, {control: '##{area}'});"
    end
  end

  def markup_editor_tag(name, value = '', options = {}, html_options = {})
    options[:delayed_load] = options[:delayed_load] === false ? false : true #defaults to true
    #
    result = markup_editor_area_tag(name, value, options, html_options)
    #
    toolbar = wikitoolbar_for("#{name}")
    if html_options[:delayed_load]
      add_footer_sript(toolbar)
    else
      result << javascript_tag("function loadToolbar() {var toolbar = new jsToolBar($('#{name}')); toolbar.draw();}; loadToolbar(); ")
    end
    result
  end

  def method_to_preview_dom(name, method, id)
     "#{name}_#{method}#{id}_preview"
  end


  private

  #do not call directly!!!!
  def markup_editor_area(name, method, options ={}, html_options ={})
    id         = options[:id]
    pl_caption = options.delete(:caption)
    pl_caption ||= "Preview #{method}"

    preview_dom_id = method_to_preview_dom(name, method, id)
    preview_target = "#{preview_dom_id}_target"

    editor_opts = {:class => 'markup-editor'}.merge(html_options)
    #links
    markup_link = link_to('Textile Markup reference', "#{ActionController::Base.asset_host}/textile_reference.html",
                    :popup => ['Textile markup reference',
                       'height=400,width=520,location=0,status=0,menubar=0,resizable=1,scrollbars=1'])
    preview_link = link_to pl_caption,
      {:controller => '/markup', :action => "preview_content", :object => name, :control => method}, {:id => "#{preview_dom_id}_link", :style => "display: none;"}

    links   = content_tag('div', markup_link + ' | ' + preview_link, {:class => 'markup-area-link'})
    #preview container
    preview_target     = content_tag('div', '&nbsp;', :id => preview_target, :class => 'markup-preview')
    preview_close_link = content_tag(:div, link_to('Close preview', '#', {:id => "#{preview_dom_id}_close", :style => "display: none;"}), {:class => 'markup-area-link'})
    preview            = content_tag('div', preview_target << preview_close_link, :id => "#{preview_dom_id}", :style => 'display: none;')
    #render all
    content_tag('div', text_area(name, method, editor_opts) << links << preview , :id => "#{name}_#{method}_editor")
  end

  #do not call directly!!!!
  def markup_editor_area_tag(name, value = '', options={}, html_options={})
    pl_caption = options.delete(:caption)
    pl_caption ||= "Preview #{name}"

    preview_dom_id = "#{name}_preview"
    preview_target = "#{name}_preview_target"

    editor_opts = {:class => 'markup-editor'}.merge(html_options)
    #links
    markup_link = link_to('Textile Markup reference', "#{ActionController::Base.asset_host}/textile_reference.html",
                    :popup => ['Textile markup reference',
                       'height=400,width=520,location=0,status=0,menubar=0,resizable=1,scrollbars=1'])
    preview_link = link_to pl_caption,
      {:controller => '/markup', :action => "preview_content", :target => name}, {:id => "#{name}_preview_link", :style => "display: none;"}

    links   = content_tag('div', markup_link + ' | ' + preview_link, {:class => 'markup-area-link'})
    #preview cntainer
    preview_close_link = content_tag(:div, link_to_function('Close preview', " Effect.toggle( $('#{preview_dom_id}'),'blind')"), {:class => 'markup-area-link'})
    preview_target     = content_tag('div', '&nbsp', :id => "#{preview_dom_id}_target", :class => 'markup-preview')
    preview            = content_tag('div', preview_target << preview_close_link, :id => "#{preview_dom_id}", :style => 'display: none;')
    #render all
    content_tag('div', text_area_tag(name, value, editor_opts) << links << preview , :id => "#{name}_editor")
  end

  def wikitoolbar_for(field_id)
    javascript_include_tag('jstoolbar/jstoolbar') +
      javascript_include_tag("jstoolbar/lang/jstoolbar-en") +
      javascript_tag("function loadToolbar() {var toolbar = new jsToolBar($('#{field_id}')); toolbar.draw();}; addEvent(window, \"load\", loadToolbar); ")
  end
    
end
