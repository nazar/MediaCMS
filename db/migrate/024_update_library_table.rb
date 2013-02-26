class UpdateLibraryTable < ActiveRecord::Migration
  def self.up
    rename_table('user_lightboxes', 'lightboxes')
    rename_column(:lightboxes, :date_added, :created_at)
    add_column(:lightboxes, :user_id, :integer)
    add_column(:lightboxes, :downloaded, :integer, {:default => 0} )
    add_column(:lightboxes, :viewed, :integer, {:default => 0} )
    
    add_index(:lightboxes, :user_id)
  end
  
  def self.down
    rename_table('lightboxes', 'user_lightboxes')
    rename_column(:user_lightboxes, :created_at, :date_added)
    remove_column(:user_lightboxes, :user_id)
    remove_column(:user_lightboxes, :downloaded)
    remove_column(:user_lightboxes, :viewed)
    
    remove_index(:user_lightboxes, :user_id)
  end
end