class BlogCreatedOnDate < ActiveRecord::Migration
  def self.up
    change_column(:blogs, :created_on, :datetime)
  end

  def self.down
    change_column(:blogs, :created_on, :integer)
  end
end
