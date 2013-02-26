class UpdateNewsItemComment < ActiveRecord::Migration
  def self.up
    add_column(:news_items, :comments_count, :integer, {:default => 0})
  end

  def self.down
    remove_column(:news_items, :comments_count)
  end
end
