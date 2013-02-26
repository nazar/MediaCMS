class CreateMenus < ActiveRecord::Migration
  def self.up
    create_table :menus do |t|
      t.column :name,        :string, :limit => 50
      t.column :description, :string, :limit => 200
    end
    add_index :menus, :name
  end

  def self.down
    drop_table :menus
  end
end
