module MenuItemsHelper

  def render_top_level_tab_menu
    title = 'Main Menu'
    #sub-methods
    def setup_main_link(in_tab)
      html_opts = {}
      html_opts[:class] = ''
      html_opts[:title] = in_tab.name if in_tab.name?
      if in_tab.highlighted
        html_opts[:class] = 'on'
        content_tag(:li, link_to("<strong><em>#{in_tab.name}</em></strong>", in_tab.menu_link), html_opts)
      else
        content_tag(:li, link_to("<em>#{in_tab.name}</em>", in_tab.menu_link), html_opts)
      end
    end
    #
    def setup_sub_link(in_tab)
      html_opts = {}
      html_opts[:class] = ''
      html_opts[:title] = in_tab.name if in_tab.name?
      html_opts[:class] = 'on' if in_tab.highlighted
      if in_tab.first
        html_opts[:class] << ' first'
      elsif in_tab.last
        html_opts[:class] << ' last'
      end
      content_tag(:li, link_to(in_tab.name, in_tab.menu_link), html_opts)
    end
    ############## MAIN ###################
    menus = MenuItem.get_cached_menu_by_name(params)
    #initialise menu array by calculating highlights and first and last items in submenus
    #each menu may have a submenu
    links = ''
    subs  = ''
    menus.each do |tab|
      links << setup_main_link(tab) if tab.display?
      if tab.highlighted && tab.has_submenues?
        tab.cached_children.each do |sub|
          subs << setup_sub_link(sub) if sub.display?
        end
      end
    end
    # #main menu
    result = content_tag(:h3, title) << content_tag(:ul, links)
    result = content_tag(:div, result, {:class => 'hd'})
    # submenu
    subs = content_tag(:h4, "submenu")  << content_tag(:ul, subs) unless subs.blank?
    result << content_tag(:div, subs, {:class => 'bd'})
    # here be divs...
    result = content_tag(:div, result, {:class => 'navset', :id => 'nav'})
    result = content_tag(:div, result, {:class => 'yui-b'})
    result = content_tag(:div, result, {:id => 'yui-main'})
    result = content_tag(:div, result, {:id => 'bd'})
    content_tag(:div, result, {:id => 'doc'})
  end

end
