class UpgradeLightboxes < ActiveRecord::Migration
  #update lightboxes table to support storing collections. Add light_type to indicate if this row is a photo or collection
  def self.up
    rename_column(:lightboxes, :photo_id, :link_id)
    add_column(:lightboxes, :link_type, :string, {:limit => 20})
    #indexes
    add_index(:lightboxes, :link_id)
    #update all light_type to Photo
    Lightbox.update_all(['link_type = ?','Photo'])
  end

  def self.down
    rename_column(:lightboxes, :link_id, :photo_id)
    remove_column(:lightboxes, :link_type)
    #
    add_index(:lightboxes, :photo_id)
  end
end
