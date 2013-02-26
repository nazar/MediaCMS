class Favouriteable < ActiveRecord::Migration
  def self.up
    add_column(:favourites, :favouriteable_id,   :integer)
    add_column(:favourites, :favouriteable_type, :string, :limit => 20)
    #
    rename_column(:favourites, :created_on, :created_at)
    #before remove need to copy photo_id to favouriteable_id and favouriteable_type
    Favourite.update_all("favouriteable_id = photo_id, favouriteable_type = 'Photo'")
    remove_column(:favourites, :photo_id)
    #
    add_index(:favourites, [:favouriteable_id, :favouriteable_type], {:name => 'i_favourites'})
  end

  def self.down
    add_column(:favourites, :photo_id, :integer)
    Favourite.update_all("photo_id = favouriteable_id")
    #
    remove_column(:favourites, :favouriteable_id)
    remove_column(:favourites, :favouriteable_type)
    #
    rename_column(:favourites, :created_at, :created_on )
    #
    add_index(:favourites, :photo_id)
  end
end
