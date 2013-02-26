require File.dirname(__FILE__) + '/../test_helper'
require 'photos_controller'

# Re-raise errors caught by the controller.
class PhotosController; def rescue_action(e) raise e end; end

class PhotosControllerTest < Test::Unit::TestCase
  
  def setup
    @controller = PhotosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #disables spider checks and bans
    @request.session[:testing] = true
 end

  context 'controller tests' do

    setup do
      @user = create_user({:active => true, :activated => true})
      @photo = create_photo(@user)
      #setup requisites
      create_categories
      @categories = Category.all
      @photo.categories = @categories
    end

    context 'anonymous users views' do

      should 'redirect to more_photos on index' do
        get :index
        assert_redirected_to :action => 'more_photos'
      end

      should 'view' do
        get :view, :id => @photo.id
        assert_response :success
      end

      should 'details' do
        get :view, :id => @photo.id
        assert_response :success
      end

      should 'not view_original when not signed in' do
        get :view_original, :id => @photo.id
        assert_response 302
      end

      should 'not editphoto when not signed in' do
        get :editphoto, :id => @photo.id
        assert_response 302
      end

      should 'preview' do
        get :preview, :id => @photo.id
        assert_template "preview"
      end

      should 'by numeric - valid' do
        get :by, :id => @user.id
        assert_template "by"
        assert_equal assigns(:photographer).id, @user.id
      end

      should 'by login - valid' do
        get :by, :id => @user.login
        assert_template "by"
        assert_equal assigns(:photographer).id, @user.id
      end

      should 'by numeric - invalid' do
        get :by, :id => 666
        assert_response 201
      end

      should 'all_by - valid' do
        get :all_by, :id => @user.login
        assert_template "all_by"
        #should have at least one photo from setup
        assert_equal assigns(:photos).length, 1, 'photo count mismatch'
      end

      should 'all_by - valid user' do
        get :all_by, :id => 'abccc'
        assert_response 201
      end

      should 'full exif' do
        get :full_exif, :id => @photo.id
        assert_template '_exif_table'
      end

      should 'not be able to delete_photo' do
        post :delete_photo, :id => @photo.id
        assert_redirected_to "/account/login"
      end

      should 'more_photos' do
        get :more_photos
        assert_template 'more_photos'
      end

      should 'photo_markers' do
        get :photo_markers, :id => @photo
      end

    end

    context 'logged in views on own photos' do

      setup do
        login_as @user
      end
      
      should 'view_original as inline' do
        get :view_original, :id => @photo.id
        assert_equal @response.headers["Content-Disposition"], "attachment; filename=\"clip0015image/bmp\""
      end

      should 'editphoto own photo' do
        get :editphoto, :id => @photo
        assert_response :success
      end

      should 'update' do
        post :update, :id => @photo, :photo => {:title => 'new title'}, :categories => [@categories[0].id, @categories[1].id]
        assert_redirected_to :action => "details"
        #check @photo was updated
        @photo.reload
        assert_equal @photo.title, 'new title', 'title mismatch'
      end

      should 'update_my_tags' do
        post :update_my_tags, :id => @photo, :user_tags => 'tag1 tag2'
        assert_redirected_to :action => "details"
        #check @photo was updated
        @photo.reload
        assert_equal @photo.tags.length, 2, 'tags mismatch'
        assert_equal @photo.tags[0].name,'tag1', 'tag1 mismatch'
        assert_equal @photo.tags[1].name,'tag2', 'tag2 mismatch'
      end

      should 'preview should not increment if viewing own photo' do
        get :preview, :id => @photo.id
        assert_template "preview"
        assert_equal @photo.previews_count, 0, 'count mismatch'
      end

      should 'favourite' do
        #check not in favourites
        assert_equal Favourite.find_favourites_for_favouriteable('Media', @photo.id).by_user(@user).length, 0, 'favourites mismatch'
        #add it
        post :favourite, :id => @photo.id
        assert_redirected_to :action => "details"
        #added to favourite?
        assert_equal Favourite.find_favourites_for_favouriteable('Media', @photo.id).by_user(@user).length, 1, 'favourites mismatch'
      end

      should 'not get delete_photo' do
        get :delete_photo, :id => @photo.id
        assert_redirected_to "/photos/more_photos"
      end

      should 'delete_photo own photo' do
        #mini setup
        count = @user.photos_count
        size  = @user.photo_space_used
        disk  = @user.disk_space_used
        #check photo file exists and counts
        assert File.exists?(@photo.original_file), 'file does not exist'
        #
        post :delete_photo, :id => @photo.id
        assert_redirected_to '/account/mypictures'
        #test file deleted
        assert !File.exists?(@photo.original_file), 'file still exists'
        #test callbacks
        @user.reload
        assert_equal @user.photos_count, count - 1, 'photo count mismatch'
        assert_equal @user.photo_space_used, size - 700854, 'photo space mismatch'
        assert_equal @user.disk_space_used, disk - 700854, 'photo space mismatch'
      end

      should 'accept file upload and create save original image' do
        post :upload_photo, :id => @user.token, :Filedata => fixture_file_upload('/files/clip0015.bmp', 'image/bmp')
        assert_response :success
        #file copied
        assert File.exists?(Photo.last.original_file), 'Upload photo not copied to library'
      end

      should 'categorise' do
        assert false
      end

      should 'upload form' do
        assert false
      end

      should 'get job list as js' do
        assert false
      end

      should 'get job list as xml' do
        assert false
      end

      context 'permissions and admin tests' do

        setup do
          user = create_user({:login => 'tste2', :email => 'tst2@email.com'})
          @photo2 = create_photo(user)
        end

        should 'not editphoto not own photo' do
          get :editphoto, :id => @photo2
          assert_template "details"
        end

        should 'not editphoto not own photo unless admin' do
          @user.admin = true
          @user.save!
          #
          get :editphoto, :id => @photo2
          assert_response :success
          assert_template "editphoto"
        end

        should 'not update anothers photo' do
          post :update, :id => @photo2, :photo => {:title => 'new title'}, :categories => [@categories[0].id, @categories[1].id]
          assert_response 401
        end

        should 'not update anothers photo unless admin' do
          @user.admin = true
          @user.save
          #
          post :update, :id => @photo2, :photo => {:title => 'new title'}, :categories => [@categories[0].id, @categories[1].id]
          assert_redirected_to :action => "details"
        end

        should 'preview should increment if viewing others photo' do
          get :preview, :id => @photo2.id
          assert_template "preview"
          @photo2.reload
          assert_equal @photo2.previews_count, 1, 'count mismatch'
        end

        should 'not delete not own delete_photo' do
          post :delete_photo, :id => @photo2.id
          assert_response 401
        end
        
        should 'reject file upload from non-user' do
          post :upload_photo, :id => '123', :Filedata => fixture_file_upload('/files/clip0015.bmp', 'image/bmp')
          assert_response 520
        end


      end


    end

    
  end

  protected

  def create_photo(user = nil)
    user ||= @user
    Photo.save_and_queue_photo_job(fixture_file_upload('/files/clip0015.bmp', 'image/bmp'), user)
    photo = Photo.last
    photo.license = License.create!(:name => 'license', :description => 'desc')
    photo.save!
    photo
  end
  
#    assert_template 'list'
#    assert_not_nil assigns(:photos)
#    assert assigns(:photo).valid?

end
