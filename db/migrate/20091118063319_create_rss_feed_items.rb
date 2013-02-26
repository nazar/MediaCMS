class CreateRssFeedItems < ActiveRecord::Migration

  def self.up
    create_table :rss_feed_items do |t|
      t.integer :rss_feed_id
      t.string :url, :title, :limit => 200
      t.text :summary, :content
      t.datetime :published
      t.integer :comments_count, :default => 0
      t.boolean :active, :default => true
      t.timestamps
    end
    add_index :rss_feed_items, :rss_feed_id, {:name => 'fk_feed'}
  end

  def self.down
    drop_table :rss_feed_items
  end

end
