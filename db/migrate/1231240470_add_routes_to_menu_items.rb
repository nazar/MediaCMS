class AddRoutesToMenuItems < ActiveRecord::Migration

  def self.up
    add_column :menu_items, :controller, :string, {:limit => 100}
    add_column :menu_items, :action, :string, {:limit => 100}
  end

  def self.down
    remove_column :menu_items, :controller
    remove_column :menu_items, :action
  end
  
end
