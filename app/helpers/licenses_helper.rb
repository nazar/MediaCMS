module LicensesHelper

  def user_licenses_listbox(name, user, selected = nil)
    all, mine = License.get_all_and_user_licenses(user)
    #
    if user.host_plan.can_sell
      my_options = ''
      if (mine.length > 0) && (user.host_plan.own_license)
        my_options <<  '<optgroup label="My Licenses">'+options_for_select(mine.map{|m| [m.name, m.id]}, selected)+'</optgroup>'
      end
      my_options << '<optgroup label="Standard Licenses">'+options_for_select(all.map{|m| [m.name, m.id]}, selected)+'</optgroup>'
    else
      free_lic = License.find(Configuration.free_license)
      my_options = "<option value='#{free_lic.id}'>#{free_lic.name}</option>"
    end
    #
    return select_tag(name, my_options, {:class => 'license_select'})
  end

  #options[:selected] expects an array of objects
  def render_license_prices(licenses, options={})
    options[:selected] = [licenses.first] if options[:selected].blank?
    options[:selected] = options[:selected].collect{|license| license.id}
    options[:class]  ||= 'options'
    #
    markaby do
      for license_price in licenses do
        disabled = (licenses.length == 1) || (not license_price.price > 0 )
        tr do
          td.check {check_box_tag "license[#{license_price.id}]", 1, options[:selected].include?(license_price.id), :class => options[:class], :disabled => disabled}
          td { link_to license_price.license.name,
              {:controller => 'licenses', :action => :view, :id => license_price.license.id },
              {:popup => ['License Information', 'height=600,width=600,scrollbars,resizable']}
             }
          td license_price.price, :align => 'right'
        end
      end
    end

  end

    
end