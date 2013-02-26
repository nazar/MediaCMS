ActionController::Base.class_eval do
  def with_helpers(&block)
    template = ActionView::Base.new([],{},self)
    template.extend self.class.master_helper_module
    add_variables_to_assigns
    template.assigns = @assigns
    template.send(:assign_variables_from_controller)
    forget_variables_added_to_assigns
    template.instance_eval(&block)
  end
end
