class ActiveNewsItem < ActiveRecord::Migration
  def self.up
    add_column(:news_items, :active, :boolean, :default => 0)
  end

  def self.down
    remove_column(:news_items, :active)
  end
end
