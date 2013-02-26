class PhotoApprovedFlag < ActiveRecord::Migration
  def self.up
    #default column already exists..replace it
    remove_column :photos, :approved
    add_column :photos, :approved, :boolean, {:default => true}
    #set all existing photos to approved
    ActiveRecord::Base.connection.execute("update photos set approved = 1")
  end

  def self.down
    #not changing anything
  end
end
