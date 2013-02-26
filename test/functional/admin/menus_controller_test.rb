require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/menus_controller'

# Re-raise errors caught by the controller.
class Admin::MenusController; def rescue_action(e) raise e end; end

class Admin::MenusControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::MenusController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
