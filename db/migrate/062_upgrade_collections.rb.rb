class UpgradeCollections < ActiveRecord::Migration
  def self.up
    add_column(:collections, :view_count, :integer, {:default => 0})
  end

  def self.down
    remove_column(:collections, :view_count)
  end
end
