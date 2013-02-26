class CreateRssFeeds < ActiveRecord::Migration
  def self.up
    create_table :rss_feeds do |t|
      t.column :name,          :string, :limit => 100
      t.column :description,   :text
      t.column :url,           :string, :limit => 200
      t.column :display_order, :integer, :default => 0
      t.column :limit_items,   :integer, :default => 5
      t.column :rss_type,      :integer
      t.column :visible,       :integer, :default => 1
    end
  end

  def self.down
    drop_table :rss_feeds
  end
end
