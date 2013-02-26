class CollectionItems < ActiveRecord::Migration

  def self.up
    rename_table :collection_items, :collections_items
  end

  def self.down
    rename_table :collections_items, :collection_items 
  end
end
