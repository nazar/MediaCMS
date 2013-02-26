class RemovePhotoState < ActiveRecord::Migration
  def self.up
    remove_column :photos, :state
  end

  def self.down
    add_column :photos, :state, :integer, {:default => 0}
  end
end
