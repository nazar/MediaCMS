class CollectionableToItem < ActiveRecord::Migration

  def self.up
    rename_column :collections_items, :collectionable_id, :item_id
    rename_column :collections_items, :collectionable_type, :item_type
  end

  def self.down
    rename_column :collections_items, :item_id, :collectionable_id 
    rename_column :collections_items, :item_type, :collectionable_type 
  end

end
