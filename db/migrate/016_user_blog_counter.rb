class UserBlogCounter < ActiveRecord::Migration
  def self.up
    add_column(:users, :blogs_count, :integer, :default => 0)
  end

  def self.down
    remove_column(:users, :blogs_count)
  end
end
