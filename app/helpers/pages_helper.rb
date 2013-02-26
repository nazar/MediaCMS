module PagesHelper

  def system_pages_listbox(name, selected)
    pages = Page.system_pages.sort
    options = ''
    #
    pages.each do |area, area_links|
      area_links = area_links.sort if area_links.length > 1
      options << "<optgroup label=\"#{area.to_s.humanize}\">" << options_for_select(area_links.sort, selected) << '</optgroup>'
    end
    #
    select_tag(name, options)
  end

end
