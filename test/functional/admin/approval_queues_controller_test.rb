require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/approval_queues_controller'

# Re-raise errors caught by the controller.
class Admin::ApprovalQueuesController; def rescue_action(e) raise e end; end

class Admin::ApprovalQueuesControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ApprovalQueuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
