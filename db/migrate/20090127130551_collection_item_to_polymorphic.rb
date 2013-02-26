class CollectionItemToPolymorphic < ActiveRecord::Migration
  
  def self.up
    add_column :collection_items, :collectionable_id, :integer
    add_column :collection_items, :collectionable_type, :string, {:limit => '30'}
    #
    add_index :collection_items, :collectionable_id
    #migrate existing photo_id column to polymorphic columns
    Photo.transaction do
      ActiveRecord::Base.connection.execute("update collection_items set collectionable_id = photo_id, collectionable_type = \"Media\"")
    end
    #finally remove photo_id after migration
    remove_column(:collection_items, :photo_id)
  end

  def self.down
    add_column :collection_items, :photo_id, :integer
    CollectionItem.update_all('photo_id = collectionable_id')
    #
    remove_column :collection_items, :collectionable_id
    remove_column :collection_items, :collectionable_type
  end

end
