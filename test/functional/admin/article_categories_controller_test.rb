require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/article_categories_controller'

# Re-raise errors caught by the controller.
class Admin::ArticleCategoriesController; def rescue_action(e) raise e end; end

class Admin::ArticleCategoriesControllerTest < Test::Unit::TestCase
  fixtures :admin_article_categories

  def setup
    @controller = Admin::ArticleCategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = article_categories(:first).id
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

    assert_not_nil assigns(:article_categories)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:article_categories)
    assert assigns(:article_categories).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:article_categories)
  end

  def test_create
    num_article_categories = ArticleCategories.count

    post :create, :article_categories => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_article_categories + 1, ArticleCategories.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:article_categories)
    assert assigns(:article_categories).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      ArticleCategories.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      ArticleCategories.find(@first_id)
    }
  end
end
