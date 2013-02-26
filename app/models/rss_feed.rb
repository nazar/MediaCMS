class RssFeed < ActiveRecord::Base

  require 'feedzirra'
  require 'open-uri'

  has_many :rss_feed_items, :dependent => :destroy

  validates_presence_of :name, :url

  DisplayVerbose = 1
  DisplaySummary = 2

  named_scope :verbose_feeds, {:conditions => ['rss_type = ?', RssFeed::DisplayVerbose]}
  named_scope :summary_feeds, {:conditions => ['rss_type = ?', RssFeed::DisplaySummary]}
  named_scope :active, {:conditions => {:visible => true}}
  named_scope :ordered, {:order => 'display_order'}

  #class methods

  def self.update_feed_from_source(feed, options = {})
    force = options[:force] == true
    if feed.next_update.blank? || (feed.next_update < Time.now) || force
      content = Feedzirra::Feed.parse( options[:use_this_content] || feed.download_feed_content )
      content.feed_url = feed.url

      feed.feed = content
      content.sanitize! if feed.sanitise
      feed.add_feed_entries(content.entries)
      feed.last_feed_date = content.last_modified
      feed.set_next_update_date

      feed.save
    end
  end


  #instance methods

  def add_feed_entries(entries)
    entries.each do |entry|
      #url should be unique in a URL feed.. check if entry doesn't exist then add
      rss = rss_feed_items.find_or_initialize_by_url( :url => entry.url)
      if rss.new_record?
        rss.attributes = {:title => entry.title, :summary => entry.summary, :content => entry.content, :published => entry.published}
        rss.save
      end
    end
  end

  def download_feed_content
    unless url.blank?
      open(url).read #open-uri
    end
  end

  def feed_as_object
    YAML::load( feed ) unless feed.blank?
  end

  def feed=(feedzirra)
    super(YAML::dump(feedzirra))
  end

  def set_next_update_date
    self.next_update = update_frequency.blank? ? 1.day.from_now : Time.now + eval(update_frequency)
  end
  
  def purge_old_feed_items
    if Configuration.purge_syndicated_items.to_i > 0
      items_count = rss_feed_items.count
      if items_count > Configuration.purge_syndicated_items.to_i
        rss_feed_items.oldest_first.all(:limit => items_count - Configuration.purge_syndicated_items.to_i).each do |item|
          item.destroy
        end
      end
    end
  end


end
