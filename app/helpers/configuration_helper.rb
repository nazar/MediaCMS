module ConfigurationHelper

  def check_box_tag_1(name, value = "1", checked = false, options = {})
    check_box_tag("#{name}", value, checked, options) << hidden_field_tag("#{name}", 0)
  end
  
end