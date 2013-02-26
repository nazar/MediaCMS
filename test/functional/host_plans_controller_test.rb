require File.dirname(__FILE__) + '/../test_helper'
require 'host_plans_controller'

# Re-raise errors caught by the controller.
class HostPlansController; def rescue_action(e) raise e end; end

class HostPlansControllerTest < Test::Unit::TestCase
  fixtures :host_plans

  def setup
    @controller = HostPlansController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:host_plans)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:host_plan)
    assert assigns(:host_plan).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:host_plan)
  end

  def test_create
    num_host_plans = HostPlan.count

    post :create, :host_plan => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_host_plans + 1, HostPlan.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:host_plan)
    assert assigns(:host_plan).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil HostPlan.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      HostPlan.find(1)
    }
  end
end
