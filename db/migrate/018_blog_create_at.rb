class BlogCreateAt < ActiveRecord::Migration
  def self.up
    add_column(:blogs, :created_at, :datetime)
    Blog.find( :all) {|b|
      b.created_at = b.created_on
      b.save
    }
    remove_column(:blogs, :created_on)
  end

  def self.down
    add_column(:blogs, :created_on, :datetime)
    Blog.find( :all) {|b|
      b.created_on = b.created_at
      b.save 
    }
    remove_column(:blogs, :created_at)
  end
end
