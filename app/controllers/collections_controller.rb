class CollectionsController < ApplicationController

  helper :comments, :feed, :forums, :markup, :photos, :medias
  
  helper :maps  
  include MapsHelper
  
  before_filter :login_required, :except => [:index, :view, :markers, :download]

  def index
    @collections = Collection.with_items.paginate :page => params[:page], :per_page => Configuration.photos_in_library_page,
                                       :order => 'created_at DESC'

    @page_title = "Viewing Photo Collections"
  end  
  
  def new
    @collection = Collection.new
    @can_sell = current_user.host_plan.can_sell
    return unless request.post?
    #
    @collection.attributes = params[:collection]
    @collection.user_id = current_user.id
    if @collection.save
      redirect_to collections_edit_path(@collection)
    else
      render :action => :new
    end
  end

  def edit
    @collection = Collection.find(params[:id])
    can_admin_collection(@collection) do
      @medias   = Media.medias_not_in_user_collection(current_user, @collection).latest_first.paginate :page => params[:page],
                                                                                                       :per_page => Configuration.collection_edit_display
      @members  = @collection.collections_items
      @can_sell = current_user.host_plan.can_sell
      @page_title = "Editing #{@collection.name}"
      return unless request.post?
      #
      @collection.attributes = params[:collection]
      @collection.user_id = current_user.id
      #
      if @collection.save
        redirect_to collections_path(@collection)
      else
        render :action => :edit
      end
    end
  end
  
  def members
    collection = Collection.find_by_id params[:id]
    redirect_to collections_path(collection) unless request.post?
    can_admin_collection(collection) do
      #action depends on whether add, add_all, remove or remove_all was pressed
      Collection.transaction do
        case
          when params[:add]
            collection.add_media_to_collection(params[:media].keys.collect{|k|k.to_i})
          when params[:add_all]
            collection.add_all_media_from_user(current_user)
          when params[:remove]
            collection.remove_collection_items(params[:item].keys.collect{|k|k.to_i})
          when params[:remove_all]
            collection.collections_items.delete
        end
      end
      redirect_to collections_path(collection)
    end
  end

  def delete
    collection = Collection.find_by_id(params[:id])
    can_admin_collection(collection) do
      Collection.transaction do
        collection.destroy
      end
      redirect_to collections_my_path
    end
  end
  
  def view
    @collection = Collection.find_by_id(params[:id])
    unless @collection.blank?
      @page_title = "Collection - #{@collection.name}"
      @collection.view_count += 1
      @collection.save
      @comment = Comment.new
      #
      @collection_items = @collection.collections_items.paginate :page => params[:page], :per_page => Configuration.photos_per_page + 10,
        :order => 'created_at DESC', :include => :item
    else
      step_notice('Invalid Collection')
    end
  end
  
  def download
    collection = Collection.find(params[:id])
    #can only download if it is free or we have purchased it
    if collection.price && collection.price > 0
      #check that we have bought this
      if current_user
        if collection.in_my_library(current_user)
          do_download_collection(collection)
        else
          step_notice('Collection not in my library. Aborting download.')
        end
      else
        step_notice('Please login first to download this collection')
      end
    else
      do_download_collection(collection)
    end
  end
  
  def add_to_lirary #TODO orpaned... add to view
    collection = Collection.find(params[:id])
    Lightbox.add_to_library(collection, current_user)
    render :update do |page|
      page.alert('Collection added to your library.')
    end
  end
  
  def markers
    collection = Collection.find(params[:id])
    render :text => markers_to_markup(collection.photo_markers)
  end

  def my
    @page_title  = 'Viewing my Photo Collection'
    @collections = current_user.collections
    @collection  = Collection.new
    @photos      = Photo.categorised.approved.by_user(current_user).paginate :page => params[:page], :per_page => Configuration.photos_per_page + 20,  #TODO configuration
      :order => 'created_on DESC'
  end


  
  protected


  
  def do_download_collection(collection)
    if collection.cache_exists_and_current
      real_file, display_file = collection.download_collection
      send_file real_file, :filename => display_file, :type => 'application/zip'
      collection.download_count += 1
      collection.save
    else
      #cache does not exist or outdated.... queue task-list to recreate and email user to wait
      Job.transaction do
        UserMailer.deliver_collection_download_being_prepared(collection, current_user)
        JobSpinner.spin_job do
          Job.enqueue_onto_queue!(:short, BackgroundWorker, :prepare_collection_cache,
                                  "Build Collection cache #{collection.name}",
                                  {:collection_id => collection.id, :user_id => current_user.id})
        end  
      end
      step_notice('We are preparing your download. You should shortly receive and email with further instructions.')
    end
  end

  def can_admin_collection(collection)
    raise "Block missing" unless block_given?
    can = admin? || (collection.user_id == curent_user.id)
    if can
      yield
    else
      step_notice('Not authorised to perform this action')
    end
  end
  
end