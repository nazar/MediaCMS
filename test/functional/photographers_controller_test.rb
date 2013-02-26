require File.dirname(__FILE__) + '/../test_helper'
require 'photographers_controller'

# Re-raise errors caught by the controller.
class PhotographersController; def rescue_action(e) raise e end; end

class PhotographersControllerTest < Test::Unit::TestCase
  fixtures :photographers

  def setup
    @controller = PhotographersController.new
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

    assert_not_nil assigns(:photographers)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:photographer)
    assert assigns(:photographer).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:photographer)
  end

  def test_create
    num_photographers = Photographer.count

    post :create, :photographer => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_photographers + 1, Photographer.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:photographer)
    assert assigns(:photographer).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Photographer.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Photographer.find(1)
    }
  end
end
