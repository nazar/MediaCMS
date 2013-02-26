module Admin::PagesHelper

  #active scaffold field overrides

  def content_form_column(record, input_name)
    markup_area :record, 'content', {:delayed_load => false}, {:name => input_name, :class => 'admin_markup_area'}
  end

  def content_type_form_column(record, input_name)
    select_tag input_name, options_for_select(Page.content_types, record.content_type)
  end


end
