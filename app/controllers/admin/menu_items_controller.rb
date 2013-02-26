class Admin::MenuItemsController < Admin::BaseController

  helper :pages

  before_filter :sub_query_filter

  active_scaffold :menu_items do |config|
    config.label = "Navigation Menu Items"
    config.list.sorting = {:position => :asc}
    #override to set display order
    config.list.columns   = [:name, :menu, :children, :link_type_desc,  :position, :visible]
    config.update.columns = [:name, :parent, :menu, :position, :conditions, :link_type, :link_url, :visible]
    config.create.columns = [:name, :parent, :menu, :position, :conditions, :link_type, :link_url, :visible]
    #    
    config.columns[:parent].form_ui = :select
    config.columns[:menu].form_ui   = :select
    config.columns[:position].inplace_edit = true
    
    config.columns[:children].label = 'Sub Menus'
    config.columns[:children].association.reverse = :parent
    config.columns[:children].includes = nil
    #
    config.subform.columns.exclude :link_type, :link_url, :children, :menu
  end
  
  def link_type_controller
    menu_item = MenuItem.find_or_initialize_by_id(params[:id])
    menu_type = params[:type]
    #
    render :update do |page|
      page.replace_html "link_url_#{menu_item.id}", render_link_url_controller(menu_item, menu_type)
    end
  end

  protected

  #activeScaffold override to display only top level menu items when in list mode
  #children can be accessed as a nested form when clicking on the children column
  def conditions_for_collection
    'menu_items.parent_id is null' if params[:nested].blank?
  end

  def sub_query_filter
    unless params[:nested].blank?
      active_scaffold_config.list.columns.exclude [:menu, :children]
      active_scaffold_config.update.columns.exclude [:menu, :children]
      active_scaffold_config.create.columns.exclude [:menu, :children]
    else
      active_scaffold_config.list.columns.add [:menu]
      active_scaffold_config.update.columns.add [:menu]
      active_scaffold_config.create.columns.add [:menu]
    end
  end


end
