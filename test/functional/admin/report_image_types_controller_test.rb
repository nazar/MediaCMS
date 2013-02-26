require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/report_image_types_controller'

# Re-raise errors caught by the controller.
class Admin::ReportImageTypesController; def rescue_action(e) raise e end; end

class Admin::ReportImageTypesControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ReportImageTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
