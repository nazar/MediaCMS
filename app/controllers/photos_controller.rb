class PhotosController < ApplicationController

  helper :categories, :comments, :feed, :forums, :licenses, :maps, :markup, :medias, :videos, :audios, :collections, :render_controls

  #mixin in the markers_to_markup from maps_helper
  include MapsHelper

  #common controller mixinc
  include MediasCommonMixin
  
  before_filter :login_required,     
                :only => [:admin_delete_photo, :admin_delete_reason, :categorise, :edit, :update, :update_my_tags, :favourite, :delete_photo,
                          :upload, :job_list, :confirm_delete, :mypictures, :stat_photos, :library, :favourites, :unapprove, :admin_unapprove ]

  verify :method => :post, :only => [ :destroy, :create, :update, :add_comment, :update_my_tags ],
         :redirect_to => { :action => :more_photos }

  cache_sweeper :media_sweeper, :only => [ :delete_photo, :update, :categorise ]

  def index
    redirect_to :action => :more_photos
  end
  
  def details
    @media = safe_find(Photo, params[:id])
    #
    valid_request_object_do(@media, 'Photo not found or is awaiting approval') do
      get_res_price_licenses_and_calc_price if request.post? #TODO move to format.html block?
      respond_to do |format|
        format.html do
          get_photo_lic_and_res_options
          if params[:submit_buy] && request.post?
            Order.transaction do
              order = get_order_from_session
              order = Order.add_media_to_order(order, @media, request.remote_ip,
                {:resolution => @res_price, :licenses => @licenses})
              session[:order_id] = order.id
            end
            redirect_to '/orders/cart'
          else
            @page_title = @media.title
            Media.increment_views_count(@media, current_user)
            @my_tags          = @media.my_tag_names(current_user) if current_user
            @photos_by_tag    = @media.similar_taggables(:limit => 8, :conditions => 'approved = 1')
            @photos_by_swatch = @media.similar_swatachables(:limit => 8, :conditions => 'approved = 1') if Configuration.color_analysis_module
            @comment          = flash[:failed] || Comment.new
            @can_edit         = @media.can_edit(current_user)
          end
        end
        format.js do
          if request.post?
            render :text => @price
          else
            render :partial => 'photos/popup_details', :locals => {:photo => @media}
          end
        end
      end
    end
  end

  #this is the original details link... keep here for a 301 redirect
  def viewphoto
    photo = Photo.find_by_id params[:id]
    redirect_to photo_view_path(photo.id, photo.safe_title), :status => 301
  end
  
  def view_original
    @photo = safe_find(Photo, params[:id])
    valid_request_object_do(@photo) do
      authorised = false
      #can only do this if photo if free or if in our collection
      if @photo.price && @photo.price > 0
        authorised = true if logged_in? && @photo.in_my_collection(current_user) || (current_user && current_user.id == @photo.user_id) || admin?
      else
        authorised = true
      end
      if authorised
        if @photo.native_browser_support
          send_file @photo.original_file, :type => 'image/jpeg', :disposition => 'inline'
        else
          send_file @photo.original_file, :filename => @photo.media_title_for_download
        end
      else
        step_notice('invalid request')
      end
    end
  end
  
  def edit
    @media = Photo.find_by_id(params[:id])
    valid_request_object_do(@media, 'No photo found') do
      Photo.transaction do
        #setup or update photo licenses and resolution prices incase new ones have been added
        MediaLicensePrice.setup_media_licenses_for_media_and_user(@media) if Configuration.multiple_license_prices
        PhotoResolutionPrice.setup_photo_resolutions_for_photo_and_user(@media) if Configuration.multiple_resolution_prices
      end
      get_photo_lic_and_res_options
      #can only edit your own photo
      if (logged_in? && (current_user.id == @media.user_id)) or (admin?)
        @selected = @media.categories.collect { |cat| cat.id.to_i }
        render :action => 'edit'
      else
        render :action => 'details'
      end
    end
  end
  
  def update
    @photo = Photo.find_by_id(params[:id])
    valid_request_object_do(@photo) do
      #save changes if I am the owner or admin
      if (current_user && (current_user.id == @photo.user_id) ) || admin?
         Photo.transaction do
           #injection prevention... user can set own price here if HTML tag known
           @photo.attributes = params[:media]
           if current_user.host_plan.can_set_price
             #multiple prices can be set here.. check if form param exists.
             if params[:license]
               MediaLicensePrice.save_media_license_prices(@photo, params[:license])
             end
             if params[:resolution_price]
               PhotoResolutionPrice.save_photo_reslution_prices(@photo, params[:resolution_price])
             end
           else 
             @photo.photo_price = Configuration.photo_default_price if params['photo_price'] && (params['photo_price'].to_f > Configuration.photo_default_price)
           end
           #approval logic
           @photo.unapprove_media unless admin?
           @photo.save!
           @photo.categories = Category.find(params[:categories])
           @photo.tag_with_by_user(params[:media][:text_tags].downcase, current_user) unless params[:media][:text_tags].nil?
         end
         #clear cache
         expire_left_block
         redirect_to photo_view_path(@photo.id, @photo.title)
      else
        render :nothing => true, :status => 401
      end
    end
  end
  
  def update_my_tags
    tags  = params[:user_tags]
    valid_request_object_do(tags) do
      unless tags.blank?
        photo = Photo.find(params[:id])
        photo.tag_with_by_user(tags.downcase, current_user)
      end
      redirect_to photo_view_path(photo.id, photo.title)
    end
  end
  
  def preview
    @photo = safe_find(Photo, params[:id])
    valid_request_object_do(@photo) do
      if (current_user && (@photo.user_id != current_user.id)) || (!current_user)
        @photo.previews_count += 1
        @photo.save
      end
      render  :layout => "plain"
    end
  end
  
  #don't add more than once into a favourites list
  def favourite
    Photo.add_to_favourite_by_media_id_and_user(params[:id], current_user)
    respond_to do |format|
      format.html {photo = Photo.find_by_id(params[:id]);  redirect_to photo_view_path(photo.id, photo.title)}
      format.js   {render :nothing => true}
    end
  end
    
  def by
    #check if :id is a number
    if params[:id].to_i > 0
      @photographer = User.find_by_id(params[:id])
    else  
      @photographer = User.find_by_login(params[:id])
    end
    valid_request_object_do(@photographer) do
      @latest_medias = Media.most_recent_by_photographer(@photographer, :limit => Configuration.photos_per_page)
      @top_medias    = Media.top_rated_by_photographer(@photographer, :limit => Configuration.photos_per_page)
      @page_title = "Viewing Photos by: #{@photographer.pretty_name}"
    end
  end
  
  def all_by
    @photographer = User.activated.find_by_login(params[:id])
    valid_request_object_do(@photographer) do
      @page_title   = "#{@photographer.pretty_name} Photographs"
      @photos       = paginate_photo_collection(@photographer.photos.categorised, :per_page =>  Configuration.photos_per_page,
                                                :order => 'created_on DESC')
    end
  end
  
  def full_exif
    photo = safe_find(Photo, params[:id])
    valid_request_object_do(photo) do
      render :partial => '/photos/exif_table', :locals => {:photo => photo}, :layout => 'head'
    end
  end
    
  #if called via JS, it will have post... otherwise, show confirm delete page
  def delete_photo
    unless request.post?
      confirm_delete
      return
    end
    photo = Photo.find_by_id(params[:id])
    valid_request_object_do(photo) do
      if photo.can_delete(current_user)
        Photo.transaction do
          photo.destroy
        end
        expire_left_block
        respond_to do |format|
          format.html {redirect_to :controller => 'photos', :action => :mypictures}
          format.js do
            render :update do |page|
              page.remove "photo_div_#{photo.id}"
            end
          end
        end
      else
        render :text => 'Invalid Request', :status => 401
      end
    end
  end

  def confirm_delete
    @media = Photo.find_by_id params[:id]
    valid_request_object_do(@media) do
      unless @media.can_delete(current_user)
        step_notice('Invalid Request')
      else
        render :action => :confirm_delete
      end
    end
  end

  def admin_delete_photo
    can_admin? do
      photo = Photo.find(params[:id])
      user  = photo.user.login
      #
      Photo.transaction do
        UserMailer::deliver_notify_delete_photo(photo, current_user, params[:reason])
        photo.destroy
      end
      expire_left_block
      redirect_to "/photos/all_by/#{user}"
    end
  end

  def admin_delete_reason
    can_admin? do
      @photo = Photo.find_by_id(params[:id])
      render :action => :admin_delete_reason, :layout => false
    end
  end

  def unapprove
    can_admin? do
      @photo = Photo.find_by_id(params[:id])
      render :action => :unapprove, :layout => false
    end
  end
  
  def admin_unapprove
    can_admin? do
      photo = Photo.find_by_id(params[:id])
      user  = photo.user.login
      Photo.transaction do
        queue = photo.unapprove_media(params[:reason])
        photo.save
        #
        UserMailer.deliver_photo_rejected(queue)
      end
      expire_left_block
      redirect_to "/photos/all_by/#{user}"
    end
  end


  def more_photos
    @page_title = 'Viewing Popular Photos'
    expire_in_5_minutes
  end

  def more_top
    @page_title = 'Top Photos'
    @photos = paginate_photo_collection(Photo.top_rated)
    render :action => :more
  end

  def more_recent
    @page_title = 'Recent Photos'
    @photos = paginate_photo_collection(Photo.most_recent)
    render :action => :more
  end

  def more_viewed
    @page_title = 'Most Viewed Photos'
    @photos = paginate_photo_collection(Photo.most_popular)
    render :action => :more
  end

  def more_votes
    @page_title = 'Most Voted Photos'
    @photos = paginate_photo_collection(Photo.most_voted)
    render :action => :more
  end

  def more_discussed
    @page_title = 'Most Discussed Photos'
    @photos = paginate_photo_collection(Photo.most_talked)
    render :action => :more
  end

  def more_favourites
    @page_title = 'Most Favourited Photos'
    @photos = paginate_photo_collection(Photo.most_favourited)
    render :action => :more
  end

  def more_sellers
    @page_title = 'Best Selling Photos'
    @photos = paginate_photo_collection(Photo.best_selling)
    render :action => :more
  end
  
  def get_photo_window_info
    @photo = Photo.find_by_id(params[:id])
    if @photo.blank?
      render :nothing => true, status => 201
    else
      render :action => :get_photo_window_info, :layout => false
    end
  end
  
  def photo_markers 
    photo = Photo.find_by_id(params[:id])
    render :text => markers_to_markup(photo.markers)
  end
  
  def markers
    markers = Photo.media_markers_by_class.all :limit => 500
    render :text => markers_to_markup(markers)
  end

  def photo_user_markers 
    user = User.find(params[:id])
    markers = user.photo_markers
    render :text => markers_to_markup(markers)
  end
  
  #called from flash file uploader
  def upload_photo
    return(render :nothing => true, :status => 500) unless request.post?
    #
    user = User.find_by_token(params[:id])
    unless user.nil?
      unless params[:Filedata].blank?
        begin
          status = Photo.save_and_queue_photo_job(params[:Filedata], user)
          if status > 0
            logger.fatal("ERROR - Photo Processing: #{Photo.status_to_text(status)}")
            render :text => 'error', :status => 500 + status
          else
            render :text => 'OK', :status => 200
          end
        rescue Exception => detail
          logger.fatal(['FATAL PHOTO ERROR - Photo Upload Exception.', detail.message, detail.backtrace.join("\n")].join{"\n"})
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


  def categorise
    return(render :nothing => true, :status => 401) unless request.post?
    photos     = params[:photo]
    #iterate through videos... get video..apply values then save
    @errors = {}
    errored_photos = []
    Photo.transaction do
      photos.each do  |id, photo|
        if photo.delete(:photo_upload)
          Photo.categorise_and_approve_media_by_id(id, photo, params[:categories], current_user) do |p|
            errored_photos << p if p.errors.length > 0
          end
        end
      end
    end
    if errored_photos.length > 0
      upload
      @unsorted_photos = errored_photos
      render :action => :upload
    else
      redirect_to :action => 'upload'
    end
  end

  def upload
    @page_title      = 'Upload Photos'
    @unsorted_photos = current_user.photos.unsorted
    @jobs            = Job.add_position_to_jobs(current_user.photo_jobs.not_failed)
  end

  def job_list
    jobs = Job.add_position_to_jobs(current_user.photo_jobs.not_failed)
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

  def by_color
    @page_title = 'Photos by Color'
    @color  = SwatchMember.find_by_id params[:color]
    @media  = Photo.find_by_id params[:id]
    @medias = paginate_photo_collection(Photo.find_by_swatch_member(params[:color]))
  end

  def same_color
    @page_title = "Photos with similar colors"
    @media = Photo.find_by_id(params[:id])
    valid_request_object_do(@media) do
      @color  = @media.swatch_members.first
      @medias = paginate_photo_collection(@media.similar_swatachables)
      render :action => :by_color
    end
  end

  def mypictures
    @photos = paginate_photo_collection(Photo.categorised.approved.by_user(current_user).date_desc)
    @page_title = 'Viewing my Photos'
  end

  def stat_photos
    @page_title = 'Viewing my Photos'
    @most_recent  = paginate_photo_collection(current_user.photos.most_recent)
    @top_rated    = paginate_photo_collection(current_user.photos.top_rated)
    @most_popular = paginate_photo_collection(current_user.photos.most_popular)
    @talked_about = paginate_photo_collection(current_user.photos.most_talked)
  end

  def library
    @page_title = 'My Photo Library'

    @lightboxes  = paginate_photo_collection(Photo.lightboxes.date_desc.by_user(current_user),
                                             :per_page => Configuration.photos_per_page)
    @collections = paginate_photo_collection(Lightbox.collections.by_user(current_user).date_desc,
                                             :per_page => Configuration.photos_per_page, :include => :link)

    #TODO currently not displaying licenses
    @licenses    = Photo.licenses.by_user(current_user).paginate :order => 'created_at DESC', :page => params[:license_page],
                                                                    :per_page => Configuration.photos_per_page  
  end

  def favourites
    @photos = paginate_photo_collection(Photo.favourited_by(current_user).date_desc)

    @page_title = 'My Favourite Photos'
  end


  
  protected


    
  def get_res_price_licenses_and_calc_price
    if @media.is_a? Photo
      @res_price = PhotoResolutionPrice.find_by_id(params[:price])
      if @res_price.photo_id != @media.id #hack attempt?
        @res_price = @media.price
      end
      if  not params[:license].blank?
        @licenses = MediaLicensePrice.find(params[:license].keys)
      elsif not @media.media_license_prices.blank? #no license given as this could be the only license choice... chose first license for photo
        @licenses = [@media.media_license_prices.first]
      else
        @licenses = []
      end
    elsif @media.is_a? Video
      @res_price = nil   #TODO do one for Video and Audio
      @licenses = [] #TODO do one for Video and Audio
    end
    @price = @res_price.price.to_f
    @licenses.each{|license| @price += license.price}
  end

  def get_photo_lic_and_res_options
    resolution_prices = PhotoResolutionPrice.photo_resolutions(@media)
    license_prices    = @media.media_license_prices
    #
    @adv_lic        = Configuration.multiple_license_prices && license_prices.length > 0
    @adv_resolution = (Configuration.multiple_resolution_prices) && (resolution_prices.length > 0)
    #determine the photo's starting price depending on the above two if price has not already been set (can be set in order_controller.buy
    if @price.nil?
      if @adv_lic || @adv_resolution
        #advanced... set price to be first of resolutions (if exists) and licenses (if exists)
        @price  = 0
        @price += license_prices.first.price unless license_prices.blank?
        @price += resolution_prices.first.price unless resolution_prices.blank?
      else
        @price = @media.price
      end
    end
  end

  def safe_find(klass, id)
    if current_user && current_user.admin?
      klass.find_by_id(id)
    else
      klass.get(id)
    end
  end

  def paginate_photo_collection(collection, options={})
    options[:page]     ||= params[:page]
    options[:per_page] ||= Configuration.more_photos_per_page
    collection.paginate :page => options[:page], :per_page => options[:per_page]
  end

end