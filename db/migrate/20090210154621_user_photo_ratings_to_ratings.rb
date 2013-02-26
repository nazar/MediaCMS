class UserPhotoRatingsToRatings < ActiveRecord::Migration
  def self.up
    rename_column :users, :photos_ratings,       :ratings
    rename_column :users, :photos_ratings_count, :ratings_count
  end

  def self.down
    rename_column :users, :ratings,       :photos_ratings
    rename_column :users, :ratings_count, :photos_ratings_count
  end
end
