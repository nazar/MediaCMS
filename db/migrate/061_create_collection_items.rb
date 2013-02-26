class CreateCollectionItems < ActiveRecord::Migration
  def self.up
    create_table :collection_items do |t|
      t.column :collection_id, :integer
      t.column :photo_id,      :integer
      t.column :created_at,    :datetime
    end
    add_index(:collection_items, :collection_id)
    add_index(:collection_items, :photo_id)
  end

  def self.down
    drop_table :collection_items
  end
end
