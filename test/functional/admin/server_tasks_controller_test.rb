require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/server_tasks_controller'

# Re-raise errors caught by the controller.
class Admin::ServerTasksController; def rescue_action(e) raise e end; end

class Admin::ServerTasksControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ServerTasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
