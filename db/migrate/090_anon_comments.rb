class AnonComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :anon_name, :string, :limit => 30
    add_column :comments, :anon_url, :string, :limit => 60
  end

  def self.down
    remove_column :comments, :anon_name, :string, :limit => 30
    remove_column :comments, :anon_url, :string, :limit => 60
  end
end
