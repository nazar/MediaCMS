class UpdateRssFeeds < ActiveRecord::Migration

  def self.up
    add_column :rss_feeds, :feed, :text
    add_column :rss_feeds, :updated_at, :datetime
    add_column :rss_feeds, :created_at, :datetime
    add_column :rss_feeds, :last_feed_date, :datetime
    add_column :rss_feeds, :sanitise, :boolean, {:default => false}
    add_column :rss_feeds, :update_frequency, :string
    add_column :rss_feeds, :next_update, :datetime
  end

  def self.down
    remove_column :rss_feeds, :feed
    remove_column :rss_feeds, :updated_at
    remove_column :rss_feeds, :created_at
    remove_column :rss_feeds, :last_feed_date
    remove_column :rss_feeds, :sanitise
    remove_column :rss_feeds, :update_frequency
    remove_column :rss_feeds, :next_update
  end

end
