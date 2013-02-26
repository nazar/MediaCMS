class AdminIntToBoolean < ActiveRecord::Migration
  def self.up
    #add tmp table to hold existing admin values
    add_column :users, :old_admin, :integer
    User.update_all('old_admin = admin')
    #change type and copy new values
    change_column(:users, :admin, :boolean)
    User.update_all('admin = true', 'old_admin = 1')
    #drop tmp column
    remove_column :users, :old_admin
  end

  def self.down
    add_column :users, :old_admin, :boolean
    User.update_all('old_admin = admin')
    #change type and copy new values
    change_column(:users, :admin, :integer)
    User.update_all('admin = 1', 'old_admin = true')
    #drop tmp column
    remove_column :users, :old_admin
  end
end
