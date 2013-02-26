class ExpireNewsArticle < ActiveRecord::Migration
  def self.up
    add_column(:news_items, :expire_item, :boolean)
    rename_column(:news_items, :expires, :expire_date)
  end

  def self.down
    remove_column(:news_items, :expire_item)
    rename_column(:news_items, :expire_date, :expires)
  end
end
