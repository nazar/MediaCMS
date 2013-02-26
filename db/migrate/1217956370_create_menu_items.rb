class CreateMenuItems < ActiveRecord::Migration
  def self.up
    create_table :menu_items do |t|
      t.column :menu_id,     :integer
      t.column :parent_id,   :integer
      t.column :name,        :string, :limit => 100
      t.column :link_type,   :integer,                    :default => 0
      t.column :link_url,    :string, :limit => 200
      t.column :description, :string, :limit => 200 #this is only a brief description
      t.column :position,    :integer
      t.column :conditions,  :string, :limit => 200
      t.column :visible,     :boolean,                    :default => true
      t.column :admin_only,  :boolean,                    :default => false
    end
    add_index :menu_items, :name
    add_index :menu_items, :menu_id
    add_index :menu_items, :parent_id
  end

  def self.down
    drop_table :menu_items
  end
end
