class CategoriesController < ApplicationController

  helper :feed, :photos, :audios, :videos
  
  def show
    @page     = params[:page]
    @category = Category.find(params[:id])
    @most_recent_photos = Photo.most_recent_in_category(@category, :limit => 5).paginate :page => params[:page], :per_page => Configuration.more_photos_per_page
    @most_recent_videos = Video.most_recent_in_category(@category, :limit => 5).paginate :page => params[:page], :per_page => Configuration.more_photos_per_page if Configuration.module_videos
    @most_recent_audios = Audio.most_recent_in_category(@category, :limit => 5).paginate :page => params[:page], :per_page => Configuration.more_photos_per_page if Configuration.module_audios
    #
    @page_title = "Viewing Media in Category: #{@category.name}"
  end

  def all_photos
    @category = Category.find(params[:id])
    @photos   = @category.photos.paginate :include => :user, :order => 'created_on DESC',
      :per_page =>  Configuration.more_photos_per_page, :page => params[:page]
    @page_title = "#{@category.name} - Viewing Photos"
  end

  def audios
    @category = Category.find(params[:id])
    @media    = @category.audios.paginate :include => :user, :order => 'created_on DESC',
      :per_page =>  Configuration.more_photos_per_page, :page => params[:page]
    @page_title = "#{@category.name} - Viewing Audio Files"
  end

  def videos
    @category = Category.find(params[:id])
    @media    = @category.videos.paginate :include => :user, :order => 'created_on DESC',
      :per_page =>  Configuration.more_photos_per_page, :page => params[:page]
    @page_title = "#{@category.name} - Viewing Videos"
  end

end