class AddUpdatedAtToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :updated_at, :datetime
  end

  def self.down
    remove_column :comments, :updated_at
  end
end
