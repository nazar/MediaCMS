class IndexOnRssFeedItemUrl < ActiveRecord::Migration

  def self.up
    add_index :rss_feed_items, :url
  end

  def self.down
    remove_index :rss_feed_items, :url
  end
end
