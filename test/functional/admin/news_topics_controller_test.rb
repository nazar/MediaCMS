require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/news_topics_controller'

# Re-raise errors caught by the controller.
class Admin::NewsTopicsController; def rescue_action(e) raise e end; end

class Admin::NewsTopicsControllerTest < Test::Unit::TestCase
  fixtures :news_topics

  def setup
    @controller = Admin::NewsTopicsController.new
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

    assert_not_nil assigns(:news_topics)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:news_topic)
    assert assigns(:news_topic).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:news_topic)
  end

  def test_create
    num_news_topics = NewsTopic.count

    post :create, :news_topic => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_news_topics + 1, NewsTopic.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:news_topic)
    assert assigns(:news_topic).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil NewsTopic.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      NewsTopic.find(1)
    }
  end
end
