class AudiosController < ApplicationController

  helper :categories, :comments, :feed, :forums, :licenses, :maps, :markup, :medias,
         :render_controls, :configuration
  #mixin in the markers_to_markup from maps_helper
  include MapsHelper

  #media controller helper mixin
  include MediasControllerHelper

  #common controller mixinc
  include MediasCommonMixin


  before_filter :login_required,
                :only => [:upload, :job_list, :categorise, :delete, :edit, :download, :favourite, :favourites, :stat_audios,
                          :admin_delete, :admin_delete_reason, :library, :my, :update, :preferences, :recode_all_user, :recode_audio]

  cache_sweeper :media_sweeper, :only => [ :delete, :update, :categorise ]

  def index
    @page_title = 'Viewing Popular Audio Files'
  end

  def view
    @media = safe_find(params[:id])
    valid_request_object_do(@media, 'Audio not found or is awaiting approval') do
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
            @page_title      = @media.title
            Media.increment_views_count(@media, current_user)
            @my_tags          = @media.my_tag_names(current_user) if logged_in?
            @audios_by_tag    = @media.similar_taggables(:limit => 8, :conditions => 'approved = 1')
            @comment          = flash[:failed] || Comment.new
            @can_edit         = @media.can_edit(current_user)
          end
        end
        format.js do
          if request.post?
            render :text => @price
          else
            render :partial => 'audios/popup_details', :locals => {:audio => @media}
          end
        end
      end
    end
  end
  
  def upload
    @page_title = 'Upload Audio Files'
    @unsorted   = current_user.audios.unsorted.converted
    @jobs       = Job.add_position_to_jobs(current_user.audio_jobs.not_failed)
  end

  def preferences
    @page_title = 'Audio File Preferences'
    @prefs = current_user.audio_preferences
    #
    return unless request.post?
    #saving
    @prefs = UserAudioPreference.find_or_initialize_by_user_id(params[:id])
    @prefs.attributes = params[:prefs]
    @prefs.save
    #
    flash[:notice] = 'Audio preferences saved' if @prefs.errors.blank?
  end

  def recode_all_user
    JobSpinner.spin_job do
      Job.enqueue_onto_queue!(:long, BackgroundWorker, :recode_all_user_audio,
                              "Recode User #{current_user.login} Audio Files ",
                              {:user_id => current_user.id})
    end
    flash[:notice] = 'Audio Recode job queued. An email will be sent once the job is complete'
    #
    @page_title = 'Audio File Preferences'
    @prefs = current_user.audio_preferences
    render :action => :preferences
  end

  def recode_audio
    audio = Audio.find_by_id params[:id]
    valid_request_object_do(audio) do
      if audio.can_edit(current_user)
        properties = MediaAudioProperty.find_or_initialize_by_audio_id(audio.id)
        properties.attributes = params[:properties]
        if properties.save
          JobSpinner.spin_job do
            Job.enqueue_onto_queue!(:long, BackgroundWorker, :recode_audio, "Recode Audio File ID: #{audio.id} ",
                                    {:audio_id => audio.id})
          end
          flash[:notice] = "Audio Recode job queued. Please wait a moment while we recode: #{audio.title}"
          redirect_to audio_path(audio)
        else
          edit(properties)
        end
      else
        redirect_to audio_path(audio)
      end
    end
  end

  def upload_audio
    return(render :nothing => true, :status => 401) unless request.post?
    user = User.find_by_token(params[:id])
    unless user.nil?
      #save and schedule conversion job
      unless params[:Filedata].blank?
        begin
          status = Audio.save_and_queue_audio_job(params[:Filedata], user)
          if status > 0
            logger.fatal("ERROR - Audio Processing: #{Audio.status_to_text(status)}")
            render :text => 'error', :status => 500 + status
          else
            render :text => 'OK', :status => 200
          end
        rescue Exception => detail
          logger.fatal(['FATAL AUDIO ERROR - Audio Upload Exception.', detail.message, detail.backtrace.join("\n")].join{"\n"})
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
    audios     = params[:audio]
    #iterate through videos... get video..apply values then save
    @errors = {}
    errored = []
    Audio.transaction do
      audios.each do  |id, audio|
        if audio.delete(:audio_upload)
          Audio.categorise_and_approve_media_by_id(id, audio, params[:categories], current_user) do |v|
            errored << v if v.errors.length > 0
          end
        end
      end
    end
    if errored.length > 0
      upload
      @unsorted = errored
      render :action => :upload
    else
      redirect_to :action => 'upload'
    end
  end

  #only and admin or video owner can delete a video
  def delete
    audio = Audio.find_by_id params[:id]
    valid_request_object_do(audio) do
      if audio.can_delete(current_user)
        Audio.transaction { audio.destroy }
        respond_to do |format|
          format.html { redirect_to audios_path}
          format.js   do #called from upload
            render :update do |page|
              page.remove "audio_div_#{audio.id}"
            end
          end
        end
      else
        render :text => 'Invalid Request', :status => 401
      end
    end
  end

  def edit(properties = nil)
    @media = Audio.find_by_id(params[:id])
    valid_request_object_do(@media, 'Invalid Audio file') do
      Audio.transaction do
        #setup or update audio licenses incase new ones have been added
        MediaLicensePrice.setup_media_licenses_for_media_and_user(@media) if Configuration.multiple_license_prices
      end
      get_media_lic_options_and_price
      #can only edit your own media
      if @media.can_edit(current_user)
        @selected = @media.categories.collect { |cat| cat.id.to_i }
        @properties = properties || @media.audio_properties #called from recode_audio
      else
        render :action => 'view'
      end
    end
  end

  def update
    @audio = Audio.find_by_id(params[:id])
    valid_request_object_do(@audio) do
      #save changes only if I am the owner or admin
      if @audio.can_edit(current_user)
         Audio.transaction do
           #injection prevention... user can set own price here if HTML tag known
           @audio.attributes = params[:media]
           if current_user.host_plan.can_set_price
             #multiple prices can be set here.. check if form param exists.
             if params[:license]
               MediaLicensePrice.save_media_license_prices(@audio, params[:license])
             end
           else 
             @audio.photo_price = Configuration.default_new_media_price if params['photo_price'] && (params['photo_price'].to_f > Configuration.default_new_media_price)
           end
           @audio.save!
           @audio.categories = Category.find(params[:categories])
           @audio.tag_with_by_user(params[:media][:text_tags].downcase, current_user) unless params[:media][:text_tags].nil?
           #do 
         end
         #clear cache
         expire_left_block
         redirect_to audio_view_path(@audio.id, @audio.title)
      else
        render :nothing => true, :status => 401
      end
    end
  end

  def favourite
    Audio.add_to_favourite_by_media_id_and_user(params[:id], current_user)
    respond_to do |format|
      format.html {media = Audio.find_by_id(params[:id]);  redirect_to audio_view_path(media.id, media.title)}
      format.js   {render :nothing => true}
    end
  end

  def favourites
    @media = Audio.favourited_by(current_user).paginate :page => params[:page], :per_page => Configuration.photos_per_page,
      :include => :user, :order => 'medias.created_on DESC'
    @page_title = 'My Favourite Audio Files'
  end


  def stat_audios
    @page_title   = 'Viewing my Audio Files - By Stats'
    @recent       = paginate_audio_collection(current_user.audios.most_recent)
    @top_rated    = paginate_audio_collection(current_user.audios.top_rated)
    @most_popular = paginate_audio_collection(current_user.audios.most_popular)
    @talked_about = paginate_audio_collection(current_user.audios.most_talked)
  end

  def admin_delete
    can_admin? do
      audio = Audio.find(params[:id])
      user  = audio.user.login
      #
      Audio.transaction do
        UserMailer::deliver_notify_delete_audio(audio, current_user, params[:reason])
        audio.destroy
      end
      expire_left_block
      redirect_to "/audios/all_by/#{user}"
    end
  end

  def admin_delete_reason
    can_admin? do
      @audio = Audio.find_by_id(params[:id])
      render :action => :admin_delete_reason, :layout => false
    end
  end

  def library
    @page_title = 'My Audio Library'

    @lightboxes  = Audio.lightboxes.by_user(current_user).paginate :order => 'created_at DESC', :page => params[:lightbox_page],
                                                                   :per_page => Configuration.photos_per_page

    #TODO currently not displaying licenses
    @licenses    = Audio.licenses.by_user(current_user).paginate :order => 'created_at DESC', :page => params[:license_page]
  end

  def my
    @media = Audio.categorised.approved.by_user(current_user).paginate :page => params[:page], :per_page => Configuration.more_photos_per_page,
      :include => :user, :order => 'created_on DESC'
    @page_title = 'Viewing my Audio Files'
  end

  def more_recent
    @page_title = 'Viewing Recent Audio Files'
    @audios = paginate_audio_collection(Audio.most_recent)
    render :action => :more
  end

  def more_viewed
    @page_title = 'Viewing Most Listened Audio Files'
    @audios = paginate_audio_collection(Audio.most_popular)
    render :action => :more
  end

  def more_votes
    @page_title = 'Viewing Most Voted Audio Files'
    @audios = paginate_audio_collection(Audio.most_voted)
    render :action => :more
  end

  def more_discussed
    @page_title = 'Viewing Most Talked About Audio Files'
    @audios = paginate_audio_collection(Audio.most_talked)
    render :action => :more
  end

  def more_favourites
    @page_title = 'Viewing Most Favourited Audio Files'
    @audios = paginate_audio_collection(Audio.most_favourited)
    render :action => :more
  end

  def more_sellers
    @page_title = 'Viewing Best Selling Audio Files'
    @audios = paginate_audio_collection(Audio.best_selling)
    render :action => :more
  end

  def job_list
    jobs = Job.add_position_to_jobs(current_user.audio_jobs.not_failed)
    unless jobs.nil?
      respond_to do |format|
        format.js  {render :partial => 'jobs/list', :locals => {:jobs => jobs}}
        format.xml {jobs.to_xml}
        format.html{render :nothing => true, :status => 401}
      end
    else
      render :nothing => true
    end
  end

  def markers
    markers = Audio.media_markers_by_class.all :limit => 500
    render :text => markers_to_markup(markers)
  end

  def user_markers
    user = User.find(params[:id])
    markers = user.audio_markers
    render :text => markers_to_markup(markers)
  end



  protected




  def safe_find(id)
    if admin?
      Audio.find_by_id(id)
    else
      Audio.get(id)
    end
  end

  def paginate_audio_collection(collection, options={})
    options[:page]     ||= params[:page]
    options[:per_page] ||= Configuration.more_photos_per_page
    collection.paginate :page => options[:page], :per_page => options[:per_page]
  end


end
