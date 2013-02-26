module MenusHelper

  def render_menu(menu = nil)
    items = menu.blank? ? MenuItem.default_items : MenuItem.named_items(menu)
    #iterate through items and it children \and render as menu
    items.each do |item|
      #render via view in /views/menus so it can be overriden by theme
    end
  end

end
