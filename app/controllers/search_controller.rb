class SearchController < ApplicationController

  helper :medias, :photos, :videos, :audios

  def index
    if request.post?
      session[:search_type] = params[:search_type]
      session[:search]      = params[:search].gsub(' ','%') if params[:search]
    end
    unless session[:search].blank?
      case session[:search_type].to_i
        when Search::TypeNameDesc;    search_by_name_description_or_id(session[:search])
        when Search::TypeCategories;  search_by_categories(session[:search])
        when Search::TypeTags;        search_by_tags(session[:search])
        when Search::TypeAuthors;     search_for_photographers(session[:search])
        when Search::TypeBlogs;       search_in_blogs(session[:search])
        when Search::TypeForums;      search_in_forums(session[:search])
        when Search::TypeCollections; search_in_collection(session[:search])
        when Search::TypeWebLinks;    search_in_links(session[:search])
      end
      return
    else
      render :text => '<h3>Empty search term used. Please type a word or sentence in the search box prior to pressing the search button</h3>',
             :layout => 'default'
    end
  end


  protected

  def search_by_name_description_or_id(search)
    if search.to_i > 0
      @media = Media.categorised.approved.find_by_id search.to_i
      if @media
        redirect_to media_view_path(@media)
      else
        redirect_to home_path
      end  
    else
      @media = Media.categorised.approved.by_name_or_description(search).paginate :page => params[:page],
                                                                                  :per_page => Configuration.more_photos_per_page, :order => 'title'
      @title = @page_title = "Searched for Media -  #{clean_search(search)}"
      render :action => :media_results
    end
  end

  def search_by_categories(search)
    @categories    = Category.find(:all, :conditions => ['name like ?',"%#{search}%"], :order => 'name')
    @title  = @page_title = "Searched for Category - #{clean_search(search)}"
    render :action => :search_category_photos
  end

  def search_by_tags(search)
    @media = Media.tagged_by_word(search).paginate :page => params[:page], :per_page => Configuration.more_photos_per_page, :order => 'title'
    @title  = @page_title = "Searched for media Tagged with - #{clean_search(search)}"
    render :action => :media_results
  end  

  def search_for_photographers(search)
    @users = User.by_name(search).paginate :page => params[:page], :per_page => 10
    @title  = @page_title = "Searched for Media Author - #{clean_search(search)}"
    render  :action => :search_photographer_photos
  end

  def search_in_blogs(search)
    @blogs = Blog.by_title_or_description(search).order_desc.paginate :page => params[:page], :per_page => Configuration.blogs_per_page
    @title  = @page_title = "Searched for Blogs with keyword - #{clean_search(search)}"
    render :action => 'search_blogs'
  end

  def search_in_forums(search)
    @topics = Post.by_title_or_body(search).with_forum.order_desc.paginate :page => params[:page], :per_page => 20 #TODO config
    @title  = @page_title = "Searched for Forums with keyword - #{clean_search(search)}"
    render :action => 'search_forums'
  end

  def search_in_collection(search)
    @collections = Collection.search(search).paginate :page => params[:page], :per_page => 20 #TODO config
    @title  = @page_title = "Searched for Collections with keyword -  #{clean_search(search)}"
    render :action => 'search_collections'
  end

  def search_in_links(search)
    @links  = Link.search(search, current_user).paginate :page => params[:page], :per_page => 20 #TODO config 
    @title  = @page_title = "Searched for Web Links with keyword - #{clean_search(search)}"
    render :action => 'search_links'
  end

  def clean_search(search)
    search.gsub('%',' ') if search
  end

  def media_view_path(media)  #TODO this is repeated in media_helper.... call from helper instead
    case media.class.name
      when "Photo"
        photo_view_link_path(media)
      when "Video"
        video_view_link_path(media)
      when "Audio"
        audio_view_link_path(media)
    end
  end


  
end
