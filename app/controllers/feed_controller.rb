class FeedController < ApplicationController

  layout 'plain'
  session :off

  helper :render_blocks, :feed, :photos, :medias, :videos, :audios

  #TODO might need pagination... look for :page params.

  def all_blogs
    @blogs = Blog.find(:all, :order => "created_at DESC", :limit => 15)
    set_headers
    record_stats('all_blogs')
  end

  def blogs_by
    @user  = User.find(params[:id])
    @blogs = @user.blogs.find(:all, :order => "created_at DESC", :limit => 15)
    set_headers
    record_stats('blogs_by',@user.id)
  end

  def site_news
    @news = NewsItem.site_news.latest_first.find(:all, :limit => 15)
    set_headers
    record_stats('site_news')
  end

  #news from all clulbs
  def clubs_news
    @news = NewsItem.club_news.latest_first.find(:all, :limit => 15)
    set_headers
    record_stats('site_news')
    render :action => :site_news
  end

  def syndicated_all
    #TODO
  end

  #club specific news
  def club_news
    @club = Club.find(params[:id])
    @news = NewsItem.find(:all, :conditions => ['club_id = ?',@club.id], :order => "created_at DESC", :limit => 15)
    set_headers
    record_stats('club_news',@club.id)
  end

  def top_photos
    @photos = Photo.find(:all, :order => "rating_total DESC", :limit => 10)
    set_headers
    record_stats('top_photos')
  end

  def latest_photos
    @photos = Photo.find(:all, :order => "created_on DESC", :limit => 10)
    set_headers
    record_stats('latest_photos')
  end

  def top_club_photos
    set_rss_feed_link
    @club   = Club.find(params[:id])
    @collection = Club.best_photos(@club, :limit => Configuration.rss_page_size, :page => @page)
    @title = "Top Club #{@club.name}Photos"
    @description = "Top photos from club #{@club.name}"
    set_headers
    render :action => :photo_feed
    record_stats('top_club_photos',@club.id)
  end

  def latest_club_photos
    set_rss_feed_link
    @club   = Club.find(params[:id])
    @collection = Club.latest_photos(@club, :limit => Configuration.rss_page_size, :page => @page)
    @title = "Latest Club #{@club.name}Photos"
    @description = "Latest photos from club #{@club.name}"
    set_headers
    render :action => :photo_feed
    record_stats('latest_club_photos',@club.id)
  end

  def latest_member_photos
    set_rss_feed_link
    @user   = User.find(params[:id])
    @collection = Photo.most_recent_by_photographer(@user, :limit => Configuration.rss_page_size, :page => @page)
    @title       = "Latest Photos by #{@user.pretty_name}"
    @description = "Displaying latest photos by #{@user.pretty_name}."
    set_headers
    render :action => :photo_feed
    record_stats('latest_member_photos',@user.id)
  end

  def top_member_photos
    set_rss_feed_link
    @user   = User.find(params[:id])
    @collection = Photo.top_rated_by_photographer(@user, :limit => Configuration.rss_page_size, :page => @page)
    @title       = "Top Rated #{@user.pretty_name} Photos"
    @description = "Displaying top rated photos by #{@user.pretty_name}."
    set_headers
    render :action => :photo_feed
    record_stats('top_member_photos',@user.id)
  end

  #get georss feed for all photos that have markers
  def photo_index_georss
    @photos = Photo.marked_objects.find(:all,  :order => 'rating_total Desc')
    set_headers
    record_stats('photo_index_georss')
  end

  def collection_photos
    set_rss_feed_link
    @album   = Collection.find_by_id params[:id]
    @collection = Photo.latest_in_collection(@album, {:limit =>  Configuration.rss_page_size, :page => @page})
    @title       = "Collection #{@album.name} Photos"
    @description = "Displaying photos in #{@album.name} collection"
    set_headers
    render :action => :photo_feed
    record_stats('collection_photos', @album.id)
  end

  def collection_georss
    @collection = Collection.find(params[:id])
    @photos = Photo.find(:all, :conditions => ["photos.id in (select ci.photo_id from collections_items ci inner join photos p on "+
                                         "                ci.photo_id = p.id inner join markers m on m.markable_id = p.id and m.markable_type = ?"+
                                         "              where ci.collection_id = ?)",'Photo',@collection.id],
                         :order => 'rating_total Desc')
    set_headers
    record_stats('collection_georss', @collection.id)
  end

  def photographer_georss
    @user = User.find(params[:id])
    @photos = Photo.find(:all, :conditions => ["photos.id in (select p.id from photos p inner join markers m on "+
                                                              " p.id = m.markable_id and m.markable_type = ? "+
                                                              "where p.user_id = ?)",'Photo',@user.id],
                         :order => 'rating_total Desc')
    set_headers
    record_stats('grapher_georss', @user.id)
  end

  def club_georss
    @club = Club.find(params[:id])
    @photos = Photo.find(:all, :conditions => ["photos.id in (select p.id from photos p inner join markers m on "+
                                                              " p.id = m.markable_id and m.markable_type = ? inner join club_members cm on "+
                                                              " p.user_id = cm.user_id "+
                                                              "where cm.club_id = ?)",'Photo',@club.id],
                         :order => 'rating_total Desc')
    set_headers
    record_stats('grapher_georss', @club.id)
  end

  def popular_links_feed(limit = 20)
    @links = Link.popular_links(limit)
    set_headers
    record_stats('popular_links')
  end

  def latest_category
    @cagegory = params[:id]
    @page     = params[:page]
  end

  def latest_in_category
    set_rss_feed_link
    @category    = Category.find_by_id params[:id]
    @collection  = Photo.most_recent_in_category(@category, {:limit => Configuration.rss_page_size, :page => @page})
    @title       = "Latest Photos in #{@category.name}"
    @description = @title
    render :action => :photo_feed   
    record_stats('latest_in_category', @category.id)
  end

  def all_in_category
    set_rss_feed_link
    @category    = Category.find_by_id params[:id]
    @collection  = @category.photos.paginate :order => 'created_on DESC', 
      :per_page =>  Configuration.rss_page_size, :page => params[:page]
    @title       = "All Photos in #{@category.name}"
    @description = @title
    render :action => :photo_feed
    record_stats('all_in_category', @category.id)
  end

  def top_in_category
    @category = Category.find_by_id params[:id]
    @photos   = Photo.top_rated_in_category(@category, :limit => Configuration.rss_page_size, :page => @page)
    set_headers
    render :action => :piclens_feed
    record_stats('top_in_category', @category.id)
  end

  def latest_in_tag
    set_rss_feed_link
    @tag    = Tag.find_by_name params[:id]
    @collection  = Photo.most_recent_in_tag(@tag, {:limit => Configuration.rss_page_size, :page => @page}) 
    @title       = "Latest Photos tagged #{@tag.name}"
    @description = @title
    render :action => :photo_feed
    record_stats('latest_in_tag', @tag.id)
  end

  def top_in_tag
    set_rss_feed_link
    @tag    = Tag.find_by_name params[:id]
    @collection  = Photo.top_rated_in_tag(@tag, {:limit => Configuration.rss_page_size, :page => @page})
    @title       = "Top Photos tagged #{@tag.name}"
    @description = @title
    render :action => :photo_feed
    record_stats('latest_in_tag', @tag.id)
  end

  def all_in_tag
    set_rss_feed_link
    @tag    = Tag.find_by_name params[:id]
    @collection = Photo.approved.tagged_by(@tag).paginate :order => 'created_on DESC',
      :per_page =>  Configuration.rss_page_size, :page => @page
    @title       = "All Photos tagged #{@tag.name}"
    @description = @title
    render :action => :photo_feed
    record_stats('latest_in_tag', @tag.id)
  end

  protected

  def set_headers
    headers["Content-Type"] = "application/rss+xml"
  end

  def record_stats(name, link_id = nil)
    RssStat.transaction do
      RssStat.add_stat(name, link_id, request.remote_ip)
    end
  end

  def set_rss_feed_link
    @page     = params[:page].blank? ? 1 : params[:page]
    @rss_link = {:controller => request.path_parameters[:controller], :action => request.path_parameters[:action], 
                 :id => request.path_parameters[:id], :format => 'rss' }
  end

end
