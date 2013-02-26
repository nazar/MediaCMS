class VideosController < ApplicationController

  helper :categories, :comments, :feed, :forums, :licenses, :maps, :markup, :medias, :render_controls
  #mixin in the markers_to_markup from maps_helper
  include MapsHelper

  #media controller helper mixin
  include MediasControllerHelper

  #common controller mixinc
  include MediasCommonMixin


  before_filter :login_required,
                :only => [:upload, :job_list, :categorise, :delete, :edit, :download, :favourite, :favourites, :stat_videos,
                          :admin_delete, :admin_delete_reason, :library, :my, :update]

  cache_sweeper :media_sweeper, :only => [ :delete, :update, :categorise ]

  def view
    @media = safe_find(Video, params[:id])
    valid_request_object_do(@media, 'Video not found or is awaiting approval') do
      get_licenses_and_calc_price if request.post?  #this is here cos requires by both html and js handlers
      respond_to do |format|
        format.html do
          get_media_lic_options_and_price
          if params[:submit_buy] && request.post?
            Order.transaction do
              order = get_order_from_session
              order = Order.add_media_to_order(order, @media, request.remote_ip, { :licenses => @licenses})
              session[:order_id] = order.id
            end
            #done... redirect to cart
            redirect_to orders_cart_path
          else
            @page_title = @media.title
            Media.increment_views_count(@media, current_user)
            @my_tags          = @media.my_tag_names(current_user) if current_user
            @videos_by_tag    = @media.similar_taggables(:limit => 8, :conditions => 'approved = 1')
            @comment          = flash[:failed] || Comment.new
            @can_edit         = @media.can_edit(current_user)
          end
        end
        format.js do
          if request.post?
            render :text => @price
          else
            render :partial => 'videos/popup_details', :locals => {:video => @media}
          end
        end
      end
    end
  end

  def upload
    @page_title      = 'Upload Videos'
    @unsorted_videos = current_user.videos.unsorted.converted
    @jobs            = Job.add_position_to_jobs(current_user.video_jobs.not_failed)
  end

  def upload_video
    return(render :nothing => true, :status => 401) unless request.post?
    user = User.find_by_token(params[:id])
    unless user.nil?
      #save and schedule conversion job
      unless params[:Filedata].blank?
        begin
          status = Video.save_and_queue_video_job(params[:Filedata], user)
          if status > 0
            logger.fatal("ERROR - Video Processing: #{Video.status_to_text(status)}")
            render :text => 'error', :status => 500 + status
          else
            render :text => 'OK', :status => 200
          end
        rescue Exception => detail
          logger.fatal(['FATAL VIDEO ERROR - Video Upload Exception.', detail.message, detail.backtrace.join("\n")].join{"\n"})
          #send back a status 500
          render :text => 'failed', :status => 500
        end
      else
        render :nothing => true, :status => 515 
      end
    else
      render :nothing => true, :status => 520
    end
  end

  def edit
    @media = Video.find_by_id(params[:id])
    valid_request_object_do(@media, 'Invalid video') do
      Video.transaction do
        #setup or update video licenses incase new ones have been added
        MediaLicensePrice.setup_media_licenses_for_media_and_user(@media) if Configuration.multiple_license_prices
      end
      get_media_lic_options_and_price
      #can only edit your own video
      if (logged_in? && (current_user.id == @media.user_id)) or (admin?)
        @selected = @media.categories.collect { |cat| cat.id.to_i }
        render :action => 'edit'
      else
        render :action => 'view'
      end
    end
  end

  def update
    @video = Video.find_by_id(params[:id])
    valid_request_object_do(@video) do
      #save changes if I am the owner or admin
      if (logged_in? && (current_user.id == @video.user_id) ) || admin?
         Video.transaction do
           #injection prevention... user can set own price here if HTML tag known
           @video.attributes = params[:media]
           if current_user.host_plan.can_set_price
             #multiple prices can be set here.. check if form param exists.
             if params[:license]
               MediaLicensePrice.save_media_license_prices(@video, params[:license])
             end
           else #TODO make default_price configurable as opposed to 1.0
             @video.photo_price = 1.0 if params['photo_price'] && (params['photo_price'].to_f > 1.0)
           end
           @video.save!
           @video.categories = Category.find(params[:categories])
           @video.tag_with_by_user(params[:media][:text_tags].downcase, current_user) unless params[:media][:text_tags].nil?
         end
         #clear cache
         expire_left_block
         redirect_to video_view_path(@video.id, @video.title)
      else
        render :nothing => true, :status => 401
      end
    end
  end

  def job_list
    jobs = Job.add_position_to_jobs(current_user.video_jobs.not_failed)
    unless jobs.nil?
      respond_to do |format|
        format.js  {render :partial => '/jobs/list', :locals => {:jobs => jobs}}
        format.xml {jobs.to_xml}
        format.html{render :nothing => true, :status => 401}
      end
    else
      render :nothing => true
    end
  end

  def categorise
    return(render :nothing => true, :status => 401) unless request.post?
    videos     = params[:video]
    #iterate through videos... get video..apply values then save
    @errors = {}
    errored_vids = []
    Video.transaction do
      videos.each do  |id, video|
        if video.delete(:video_upload)
          Video.categorise_and_approve_media_by_id(id, video, params[:categories], current_user) do |v|
            errored_vids << v if v.errors.length > 0
          end
        end
      end
    end
    if errored_vids.length > 0
      upload
      @unsorted_videos = errored_vids
      render :action => :upload
    else
      redirect_to :action => 'upload'
    end
  end

  def index
    @page_title = 'Viewing Popular Videos'
    #TODO clear cache
  end

  #only and admin or video owner can delete a video
  def delete
    video = Video.find_by_id params[:id]
    valid_request_object_do(video) do
      if video.can_delete(current_user)
        Video.transaction { video.destroy }
        respond_to do |format|
          format.html { redirect_to videos_path}
          format.js   do
            render :update do |page|
              page.remove "video_div_#{video.id}"
            end
          end
        end
      else
        render :text => 'Invalid Request', :status => 401
      end
    end
  end

  def my
    @videos = paginate_video_collection(Video.categorised.approved.by_user(current_user).date_desc)
    @page_title = 'Viewing my Videos'
  end

  def stat_videos
    @page_title   = 'Viewing my Videos - By Stats'
    @recent       = paginate_video_collection(current_user.videos.most_recent)
    @top_rated    = paginate_video_collection(current_user.videos.top_rated)
    @most_popular = paginate_video_collection(current_user.videos.most_popular)
    @talked_about = paginate_video_collection(current_user.videos.most_talked)
  end

  def library
    @page_title = 'My Video Library'

    @lightboxes  = Video.lightboxes.by_user(current_user).paginate :order => 'created_at DESC', :page => params[:lightbox_page],
                                                                  :per_page => Configuration.photos_per_page

    #TODO currently not displaying licenses
    @licenses    = Video.licenses.by_user(current_user).paginate :order => 'created_at DESC', :page => params[:license_page]
  end

  def my_favourites
  end

  def top
    #TODO
  end

  def more_recent
    @page_title = 'Viewing Recent Videos'
    @videos = paginate_video_collection(Video.most_recent)
    render :action => :more
  end

  def more_viewed
    @page_title = 'Viewing Most Listened Videos'
    @videos = paginate_video_collection(Audio.most_popular)
    render :action => :more
  end

  def more_votes
    @page_title = 'Viewing Most Voted Videos'
    @videos = paginate_video_collection(Audio.most_voted)
    render :action => :more
  end

  def more_discussed
    @page_title = 'Viewing Most Talked About Videos'
    @videos = paginate_video_collection(Video.most_talked)
    render :action => :more
  end

  def more_favourites
    @page_title = 'Viewing Most Favourites Videos'
    @videos = paginate_video_collection(Audio.most_favourited)
    render :action => :more
  end

  def more_sellers
    @page_title = 'Viewing Best Selling Videos'
    @videos = paginate_video_collection(Audio.best_selling)
    render :action => :more
  end

  #don't add more than once into a favourites list
  def favourite
    Video.add_to_favourite_by_media_id_and_user(params[:id], current_user)
    respond_to do |format|
      format.html {video = Video.find_by_id(params[:id]);  redirect_to video_view_path(video.id, video.title)}
      format.js   {render :nothing => true}
    end
  end

  def admin_delete
    can_admin? do
      video = Video.find(params[:id])
      user  = video.user.login
      #
      Video.transaction do                     #TODO complete
        UserMailer::deliver_notify_delete_video(video, current_user, params[:reason])
        video.destroy
      end
      expire_left_block
      redirect_to "/videos/all_by/#{user}"
    end
  end

  def admin_delete_reason
    can_admin? do
      @video = Video.find_by_id(params[:id])
      render :action => :admin_delete_reason, :layout => false
    end
  end

  def markers
    markers = Video.media_markers_by_class.all :limit => 500
    render :text => markers_to_markup(markers)
  end

  def user_markers
    user = User.find(params[:id])
    markers = user.video_markers
    render :text => markers_to_markup(markers)
  end

  def favourites
    @videos = Video.favourited_by(current_user).paginate :page => params[:page], :per_page => Configuration.photos_per_page,
      :include => :user, :order => 'medias.created_on DESC'

    @page_title = 'My Favourite Videos'
  end


  
  protected



  def safe_find(klass, id)
    if admin?
      klass.find_by_id(id)
    else
      klass.get(id)
    end
  end

  def paginate_video_collection(collection, options={})
    options[:page]     ||= params[:page]
    options[:per_page] ||= Configuration.more_photos_per_page
    collection.paginate :page => options[:page], :per_page => options[:per_page]
  end




end
