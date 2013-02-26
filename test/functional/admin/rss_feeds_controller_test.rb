require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/rss_feeds_controller'

# Re-raise errors caught by the controller.
class Admin::RssFeedsController; def rescue_action(e) raise e end; end

class Admin::RssFeedsControllerTest < Test::Unit::TestCase
  fixtures :admin_rss_feeds

  def setup
    @controller = Admin::RssFeedsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = rss_feeds(:first).id
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

    assert_not_nil assigns(:rss_feeds)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:rss_feed)
    assert assigns(:rss_feed).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:rss_feed)
  end

  def test_create
    num_rss_feeds = RssFeed.count

    post :create, :rss_feed => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_rss_feeds + 1, RssFeed.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:rss_feed)
    assert assigns(:rss_feed).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      RssFeed.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      RssFeed.find(@first_id)
    }
  end
end
