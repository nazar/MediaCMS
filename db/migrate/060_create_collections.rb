class CreateCollections < ActiveRecord::Migration
  def self.up
    create_table :collections do |t|
      t.column :user_id,                :integer
      t.column :name,                   :string
      t.column :description,            :text
      t.column :price,                  :float, :default => 0.0
      t.column :created_at,             :datetime
      t.column :collection_items_count, :integer, :default => 0
      t.column :download_count,         :integer, :default => 0
      t.column :sold_count,             :integer, :default => 0
      t.column :total_sales,            :float,   :default => 0
    end
    add_index(:collections, :user_id)
  end

  def self.down
    drop_table :collections
  end
end
