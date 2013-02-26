require File.dirname(__FILE__) + '/../test_helper'
require 'menu_items_controller'

# Re-raise errors caught by the controller.
class MenuItemsController; def rescue_action(e) raise e end; end

class MenuItemsControllerTest < Test::Unit::TestCase
  def setup
    @controller = MenuItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
