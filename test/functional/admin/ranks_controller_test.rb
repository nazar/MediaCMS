require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/ranks_controller'

# Re-raise errors caught by the controller.
class Admin::RanksController; def rescue_action(e) raise e end; end

class Admin::RanksControllerTest < Test::Unit::TestCase
  fixtures :ranks

  def setup
    @controller = Admin::RanksController.new
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

    assert_not_nil assigns(:ranks)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:rank)
    assert assigns(:rank).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:rank)
  end

  def test_create
    num_ranks = Rank.count

    post :create, :rank => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_ranks + 1, Rank.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:rank)
    assert assigns(:rank).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Rank.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Rank.find(1)
    }
  end
end
