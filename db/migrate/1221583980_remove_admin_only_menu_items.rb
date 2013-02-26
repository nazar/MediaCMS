class RemoveAdminOnlyMenuItems < ActiveRecord::Migration
  def self.up
    remove_column :menu_items, :admin_only
  end

  def self.down
    add_column :menu_items, :admin_only, :boolean, {:default => false}
  end
end
