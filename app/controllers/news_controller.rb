class NewsController < ApplicationController
  
  helper :markup, :comments, :feed
  
  def index
    @site_news  = NewsItem.latest_active_items(1).site_news
    @club_news  = NewsItem.latest_active_items(1).club_news
    @vfeeds     = RssFeed.verbose_feeds.active.ordered
    @page_title = "Site News"
  end
  
  def show
    @news_item = NewsItem.find(params[:id])
    NewsItem.increment_views(@news_item)
    @comment  = Comment.new
    @page_title = "#{@news_item.title}"
  end

  def view_feed_item
    @rss_item = RssFeedItem.find_by_id(params[:id])
    RssFeedItem.increment_views(@rss_item)
    @comment  = Comment.new
    @page_title = "#{@rss_item.title}"
  end

  def site
    @site_news  = NewsItem.site_news.latest_first.paginate :page => params[:page]
    @page_title = "Site News"
  end

  def clubs
    @club_news  = NewsItem.club_news.latest_first.paginate :page => params[:page]
    @page_title = "Club News"
  end

  def syndicated
    @vfeeds     = RssFeed.verbose_feeds.active.ordered
    @page_title = "Syndicated News"
  end
  
  def syndicated_history
    @feed = RssFeed.verbose_feeds.find_by_id params[:id]
    @feed_items = @feed.rss_feed_items.ordered.paginate :page => params[:page]
    @page_title = "#{@feed.name} - All Articles"
  end

end
