module ApplicationHelper

  def indented_categories_select(selected = nil)
    ret = '';
    bold = ''
    tree_recursive(Category.all,nil) do |t, level|
      if level == 5
        bold = 'class="bold"'
      else
        bold = ''
      end

      if selected && selected.index(t.id)
        ret << "<option style='padding-left:#{level.to_s}px' value='#{t.id}' selected='selected' #{bold} >#{t.name}</option>"
      else
        ret << "<option style='padding-left:#{level.to_s}px' value='#{t.id}' #{bold}>#{t.name}</option>"
      end
    end
    return ret
  end

  def display_tree_indented(tree)
    tree_recursive(tree) do |cat,level|
      "<div class='category' style='padding-left:#{level.to_s}px'>"+ yield(cat) +'</div>'
    end
  end

  def tree_recursive(tree, parent_id = nil, level = -5)
    ret = '';
    level += 10
    tree.each do |node|
      if node.parent_id == parent_id
        ret << (yield node, level)
        ret << tree_recursive(tree, node.id, level) { |n,l| yield n, l }
      end
    end
    ret << ""
  end

  def toggle_menu_to_category(category, options = {})
    options[:indicator] = options[:indicator] === false ? false : true
    sym_open   = options[:indicator] ? '[+] ' : ''
    sym_closed = options[:indicator] ? '[-] ' : ''
    #
    if category.parent
      recurse_cats(category.parent){|c| "toggle(#{c.id}, '#{sym_open}', '#{sym_closed}');"}
    else
      "toggle(#{category.id}, '#{sym_open}', '#{sym_closed}')"
    end
  end

  def recurse_cats(category)
    script = ''
    if category
      script += yield category
    end
    if category.parent
      script += recurse_cats(category.parent){|c| yield c}
    end
    return script
  end

  def date_ago(date)
    if date.to_i > 0
      time_ago_in_words(date)
    end
  end

  def render_select(name, options, selected)
    select = "<select name='#{name}' id='#{name}'>"
    options.map do |o|
      if o == selected
        select << "<option value='#{options.index(o)}' selected='selected'>#{o}</option>"
      else
        select << "<option value='#{options.index(o)}'>#{o}</option>"
      end
    end
    select << '</select>'
  end

  def options_by_id(name, options, selected)
    select = "<select name='#{name}' id='#{name}'>"
    options.each do |o|
      if o.last.to_i == selected.to_i
        select << "<option value='#{o.last}' selected='selected'>#{o.first}</option>"
      else
        select << "<option value='#{o.last}'>#{o.first}</option>"
      end
    end
    select << '</select>'
  end

  #options[:escape] - element of tags to escape i.e. (['pre','code']) or a string for a single element ie ('pre')
  def format_red_cloth(body, options={}) #TODO use sage code for correct escape code
    unless body.blank?
      #escape and textalise
      rc = RedCloth.new(h(body))
      body = rc.to_html
      #replace place back manual escapes
      unless options.blank? || options[:escape].blank?
        body = CGI::unescapeElement(body, options[:escape])
      end
      body
    end
  end

  def current_domain
    request.protocol + request.host_with_port + '/'
  end

  def render_tab_main_nav(tabs, title = 'Main Menu')
    #sub-methods
    def setup_main_link(in_tab)
      html_opts = {}
      html_opts[:class] = ''
      html_opts[:title] = in_tab.title if in_tab.title
      html_opts[:class] = 'on' if in_tab.highlighted
      if in_tab.highlighted
        content_tag(:li, link_to("<strong><em>#{in_tab.name}</em></strong>", in_tab.link), html_opts)
      else
        content_tag(:li, link_to("<em>#{in_tab.name}</em>", in_tab.link), html_opts)
      end
    end

    def setup_sub_link(in_tab)
      html_opts = {}
      html_opts[:class] = ''
      html_opts[:title] = in_tab.title if in_tab.title
      html_opts[:class] = 'on' if in_tab.highlighted
      if in_tab.first_tab
        html_opts[:class] << ' first'
      elsif in_tab.last_tab
        html_opts[:class] << ' last'
      end
      content_tag(:li, link_to(in_tab.name, in_tab.link), html_opts)
    end
    # main #
    subs =  ''
    links = ''
    FrontpageleftTabnav.mark_highlighted(tabs, params) {|tab| eval(tab.condition)}
    #
    tabs.each do |tab|
      links << setup_main_link(tab) if eval(tab.condition)
      if tab.highlighted && tab.has_submenu
        tab.submenus.each do |sub|
          subs << setup_sub_link(sub) if eval(sub.condition)
        end
      end
    end
    # #main menu
    result = content_tag(:h3, title) + content_tag(:ul, links)
    result = content_tag(:div, result, {:class => 'hd'})
    # submenu
    subs = content_tag(:h4, "submenu")  + content_tag(:ul, subs)
    result << content_tag(:div, subs, {:class => 'bd'})
    # here be divs...
    result = content_tag(:div, result, {:class => 'navset', :id => 'nav'})
    result = content_tag(:div, result, {:class => 'yui-b'})
    result = content_tag(:div, result, {:id => 'yui-main'})
    result = content_tag(:div, result, {:id => 'bd'})
    result = content_tag(:div, result, {:id => 'doc'})
    result
  end

  def add_extra_header_content(content) #TODO add block processing 
    @extra_header_content ||= ''
    @extra_header_content << content << ' '
  end

  def get_extra_header_content
    @extra_header_content ||= ''
    @extra_header_content
  end

  def add_footer_sript(script)
    @last_scripts ||= '';
    @last_scripts << script
  end

  def get_footer_script
    @last_scripts ||= '';
    @last_scripts
  end

  def dom_id(obj)
    klass = obj.class.to_s.underscore
    "#{klass}[#{obj.id}]"
  end

  def markaby(&block)
    Markaby::Builder.new({}, self, &block)
  end

  def periodically_call_remote(options = {})
    variable = options[:variable] ||= 'poller'
    frequency = options[:frequency] ||= 10
    code = "#{variable} = new PeriodicalExecuter(function() {#{remote_function(options)}}, #{frequency})"
    javascript_tag(code)
  end

  def jquery_include_tag(*libs)
    js_libs = []
    js_opts = {}
    libs.each do |library|
      case
        when library.is_a?(String)
          js_libs << "jquery/#{library}"
        when library.is_a?(Hash)
          js_opts.merge!(library)
      end
    end
    javascript_include_tag js_libs, js_opts
  end

  def h2_title(title)
    content_tag(:div, content_tag(:h2, title), :class => 'block_title')
  end

  def step_notice(content)
    render :partial => 'shared/notice',
           :locals => {:content => content},
           :layout => true
  end

  def render_flash(key)
    unless flash[key].blank?
      content_tag(:div, flash[key], :class => key.to_s)
    end
  end


end
