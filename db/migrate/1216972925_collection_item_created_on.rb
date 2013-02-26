class CollectionItemCreatedOn < ActiveRecord::Migration
  def self.up
    add_column :collection_items, :created_on, :datetime
    #copy over all created_at
    Photo.transaction do
      ActiveRecord::Base.connection.execute("update collection_items set created_on = created_at")
    end
  end

  def self.down
    add_column :collection_items, :created_on
  end
end
