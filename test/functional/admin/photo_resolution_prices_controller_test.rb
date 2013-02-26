require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/photo_resolution_prices_controller'

# Re-raise errors caught by the controller.
class Admin::PhotoResolutionPricesController; def rescue_action(e) raise e end; end

class Admin::PhotoResolutionPricesControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::PhotoResolutionPricesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
