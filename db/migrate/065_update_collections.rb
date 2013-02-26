class UpdateCollections < ActiveRecord::Migration
  def self.up
    add_column(:collections, :collection_size, :integer, {:default => 0})
    #update this for existing collections
    sql = ActiveRecord::Base.connection();
    sql.update "update collections set collection_size = (select sum(photos.file_size) from photos inner join collection_items on photos.id = collection_items.photo_id where collection_items.collection_id = collections.id)"
  end

  def self.down
  end
end
