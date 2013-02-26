require File.dirname(__FILE__) + '/../test_helper'
require 'videos_controller'

class VideosControllerTest < ActionController::TestCase

  def setup
    @controller = VideosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #create entities required for user testing
    #hosting plans
    @request.session[:testing] = true
  end

  context 'video controller tests' do

    setup do
      @user = create_user
    end

    context 'video upload' do

      should 'reject non POST requests' do
        get :upload_video
        assert_response 401
      end

      should 'accept file upload and create save original image' do
        post :upload_video, :id => @user.token, :Filedata => fixture_file_upload('/files/2.avi', 'stream/octet')
        assert_response :success
      end

      context 'user counters' do

        setup do
          @videos_count = @user.videos_count
          @size_count   = @user.disk_space_used
          #post it
          post :upload_video, :id => @user.token, :Filedata => fixture_file_upload('/files/2.avi', 'stream/octet')
        end

        should 'increment user counters' do
          user = User.find_by_id @user.id
          assert_equal user.videos_count,    1,         'count counter mismatch'
          assert_equal user.disk_space_used, 71071744,  'size counter mismatch'
        end
        
      end

    end

    context 'video uploads' do

      setup do
        #setup requisites
        create_categories
        #upload video
        post :upload_video, :id => @user.token, :Filedata => fixture_file_upload('/files/2.avi', 'stream/octet')
        @video = Video.last
        @categories = Category.all
        #finally...login
        login_as @user
      end

      should 'categories videos' do
        #build videos hashes for save
        post :categorise, :video => { @video.id => {:title => 'test title', :price => 1.1, :description => 'test desc',
          :text_tags => 'tag1 tag2 "tag 3"', :video_upload => 1}}, :categories => {@video.id => [@categories[0].id, @categories[1].id]}
        #200?
        assert_redirected_to :action => :upload
        #lets test!!
        video = Video.find_by_id @video.id
        #
        assert_equal video.title,             'test title', 'title does not match'
        assert_equal video.price,             1.0,          'price does not match'
        assert_equal video.description,       'test desc',  'desc does not match'
        assert_equal video.tags.length,       3,            'tags does not match'
        assert_equal video.categories.length, 2,            'cats does not match'
      end


    end

  end
  
end
