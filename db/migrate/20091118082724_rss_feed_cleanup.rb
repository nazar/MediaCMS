class RssFeedCleanup < ActiveRecord::Migration

  def self.up
    drop_table :cached_feeds
    add_column :rss_feed_items, :views_count, :integer, {:default => 0}
  end

  def self.down
    RssCache.up
    remove_column :rss_feed_items, :views_count
  end
end
