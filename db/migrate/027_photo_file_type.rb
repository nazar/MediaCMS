class PhotoFileType < ActiveRecord::Migration
  def self.up
    add_column(:photos, :file_type, :string, {:length => 30})
  end
  
  def self.down
    remove_column(:photos, :file_type)
  end
end