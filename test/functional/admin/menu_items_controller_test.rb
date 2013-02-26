require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/menu_items_controller'

# Re-raise errors caught by the controller.
class Admin::MenuItemsController; def rescue_action(e) raise e end; end

class Admin::MenuItemsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::MenuItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
