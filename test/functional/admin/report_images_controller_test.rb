require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/report_images_controller'

# Re-raise errors caught by the controller.
class Admin::ReportImagesController; def rescue_action(e) raise e end; end

class Admin::ReportImagesControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ReportImagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
