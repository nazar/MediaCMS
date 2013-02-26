class DefaultExpireItemValue < ActiveRecord::Migration
  def self.up
    change_column(:news_items, :expire_item, :boolean, :default => 0)
  end

  def self.down
    change_column(:news_items, :expire_item, :boolean)
  end
end
