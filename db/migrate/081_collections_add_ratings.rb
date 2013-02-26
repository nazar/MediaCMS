class CollectionsAddRatings < ActiveRecord::Migration
  def self.up
    add_column(:collections, :ratings_count, :integer, {:default => 0})
    add_column(:collections, :rating_total, :integer, {:default => 0})
    #set all existing to 0
    Collection.update_all('ratings_count = 0, rating_total = 0')
  end

  def self.down
    remove_column(:collections, :ratings_count)
    remove_column(:collections, :rating_total)
  end
end
