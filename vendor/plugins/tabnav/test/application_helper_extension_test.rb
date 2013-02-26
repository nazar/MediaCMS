require 'test/unit'
require 'init'

class ActionViewExtensionTest < Test::Unit::TestCase

  def setup
    @view = ActionView::Base.new
    @view.extend ApplicationHelper
  end
    
  def test_presence_of_instance_methods
    %w{tabnav}.each do |instance_method|
      assert @view.respond_to?(instance_method), "#{instance_method} is not defined in #{@controller.inspect}" 
    end     
  end  
  
end