class PhotosCreatedDateIndex < ActiveRecord::Migration
  def self.up
    add_index(:photos, :created_on)
  end

  def self.down
    remove_index(:photos, :created_on)
  end
end
