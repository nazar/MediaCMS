class CategoryPhotosCountToMemberCount < ActiveRecord::Migration

  def self.up
    rename_column :categories, :photos_count, :members_count
  end

  def self.down
    rename_column :categories, :members_count, :photos_count 
  end
end
