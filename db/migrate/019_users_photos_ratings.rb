class UsersPhotosRatings < ActiveRecord::Migration
  def self.up
    add_column(:users, :photos_ratings, :integer, :default => 0)
  end

  def self.down
    remove_column(:users, :photos_ratings)
  end
end
