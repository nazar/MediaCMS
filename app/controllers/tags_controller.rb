class TagsController < ApplicationController

  helper :feed, :photos, :videos, :audios, :medias

  def index
    redirect_to :action => :photos
  end

  def show
    @tag = Tag.find_by_name(params[:id])
    @medias = Media.find_tagged_with(@tag.name).paginate :page => params[:page], :per_page => Configuration.more_photos_per_page,
                                                         :order => 'medias.created_on DESC'
    @page_title = "Viewing medias tagged  #{@tag.name}"
  end

  def photos
    @tags, @min_count, @max_count = Photo.top_tags_min_max(100)
    @page_title = "Viewing tags cloud"
  end

  def photo #TODO add pagination
    @tag = Tag.find_by_name(params[:id].gsub('^^','.'))
    @photos_count = Photo.find_tagged_with([@tag.name]).count
    @page_title = "Viewing Photos Tagged with #{@tag.name}"
  end

  def videos
    @tags, @min_count, @max_count = Video.top_tags_min_max(100)
    @page_title = "Viewing Video tags cloud"
  end

  def video #TODO add pagination
    @tag = Tag.find_by_name(params[:id].gsub('^^','.'))
    @videos_count = Video.find_tagged_with([@tag.name]).count
    @page_title = "Viewing Videos Tagged with #{@tag.name}"
  end

  def audios
    @tags, @min_count, @max_count = Audio.top_tags_min_max(100)
    @page_title = "Viewing Audio tags cloud"
  end

  def audio #TODO add pagination
    @tag = Tag.find_by_name(params[:id].gsub('^^','.'))
    @audios_count = Audio.find_tagged_with([@tag.name]).count
    @page_title = "Viewing Audio Files Tagged with #{@tag.name}"
  end

  def all_audios
    @tag = Tag.find_by_name(params[:id].gsub('^^','.'))
    @medias = Audio.approved.tagged_by(@tag).paginate :order => 'created_on DESC',
      :per_page =>  Configuration.more_photos_per_page, :page => params[:page]
    @page_title = "Viewing All Audio Files Taged with #{@tag.name}"
  end

  def show_clubs
    @tag = Tag.find_by_name(params[:id].gsub('^^','.'))
  end
  
  def all_photos
    @tag = Tag.find_by_name(params[:id].gsub('^^','.'))
    @photos = Photo.approved.tagged_by(@tag).paginate :order => 'created_on DESC',
      :per_page =>  Configuration.more_photos_per_page, :page => params[:page]
    @page_title = "Viewing Photos Taged with #{@tag.name}"
  end
  
  def my_tags
    @tag    = Tag.find_by_name(params[:id])
    @user   = User.find_by_login(params[:user])
    @photos = Photo.categorised.approved.tagged_by(@tag).owned_by(@user).paginate :page => params[:page], :per_page => Configuration.more_photos_per_page,
      :order => 'created_on DESC'
  end
  
  def articles
    begin
      @tag = Tag.find_by_name(params[:id])
      #find articles with this tag
      @articles = Article.articles_tagged_with(@tag)
    rescue
      step_notice('Tag not found')
    end
  end
  
end