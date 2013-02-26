class VideoCategories < ActiveRecord::Migration
  def self.up
    create_table :categories_videos, :id => false do |t|
      t.column :video_id, :integer
      t.column :category_id, :integer
    end
    add_index :categories_videos, :video_id
    add_index :categories_videos, :category_id
  end

  def self.down
    drop_table :categories_videos
  end
end
