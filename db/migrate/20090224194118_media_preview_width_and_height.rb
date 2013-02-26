class MediaPreviewWidthAndHeight < ActiveRecord::Migration
  def self.up
    add_column :medias, :preview_width, :integer
    add_column :medias, :preview_height, :integer
  end

  def self.down
    remove_column :medias, :preview_width
    remove_column :medias, :preview_height
  end
end
