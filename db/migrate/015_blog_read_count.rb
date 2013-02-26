class BlogReadCount < ActiveRecord::Migration
  def self.up
    add_column(:blogs, :blog_read, :integer, :default => 0)
  end

  def self.down
    remove_column(:blogs, :blog_read)
  end
end
