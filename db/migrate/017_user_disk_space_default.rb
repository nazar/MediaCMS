class UserDiskSpaceDefault < ActiveRecord::Migration
  def self.up
    change_column(:users, :disk_space_used, :integer, :default => 0)
    change_column(:users, :credits, :integer, :default => 0)
  end

  def self.down
    change_column(:users, :disk_space_used, :integer)
    change_column(:users, :credits, :integer)
  end
end
