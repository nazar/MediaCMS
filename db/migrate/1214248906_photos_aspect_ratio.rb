class PhotosAspectRatio < ActiveRecord::Migration
  def self.up
    add_column :photos, :aspect_ratio, :float
    add_index :photos, :aspect_ratio
    #iterate through existing photos and calculate aspect ratio
    Photo.transaction do
      ActiveRecord::Base.connection.execute("update photos set aspect_ratio = (width / height) where height > 0")
    end
  end

  def self.down
    remove_column :photos, :aspect_ratio
  end
end
