module Admin::MenuItemsHelper
  
  #override to only list parents that have no children as this is only one level deep
  def parent_form_column(record, input_name)
    items = {'top level' => nil}
    MenuItem.top_level.collect{|menu| items[menu.name] = menu.id}
    select_tag input_name, options_for_select(items, record.parent_id)
  end

  def menu_form_column(record, input_name)
    items = {'default' => nil}
    Menu.find(:all, :order => 'name').collect{|menu| items[menu.name] = menu.id}
    select_tag input_name, options_for_select(items, record.menu_id)
  end

  def link_type_form_column(record, input_name)
    column = select_tag input_name, options_for_select(MenuItem.link_types.sort, record.link_type), :class => 'admin_link_type_select'
    column << javascript_tag("jQuery('.admin_link_type_select').attach(RemoteUpdateSelectOnChange, {url: '/admin/menu_items/link_type_controller/#{record.id}'});")
  end

  #link_url will depend on what is selected in link_type
  def link_url_form_column(record, input_name)
    content_tag(:div, render_link_url_controller(record, record.link_type),:id => "link_url_#{record.id}")
  end
  
  def render_link_url_controller(item, control)
    case control.to_i
    when 0 #not a link
      'Will display name only'
    when 1 #system pages
      system_pages_listbox('record[link_url]', item.link_url)
    when 2 #static pages
      select_tag 'record[link_url]', options_for_select(Page.pages.collect{|page| [page.name, page.id]}, item.link_url)
    when 3
      text_field_tag 'record[link_url]', item.link_url
    end
  end
  
end
