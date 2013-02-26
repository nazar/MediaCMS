class UpdateClubs < ActiveRecord::Migration
  def self.up
    #update clubs table to support address
    add_column(:clubs, :address, :text)
    add_column(:clubs, :country, :string, :limit => 60)
    add_column(:clubs, :county, :string, :limit => 60)
    #add application field to club_members table
    add_column(:club_members, :application, :text)
  end

  def self.down
    remove_column(:clubs, :address)
    remove_column(:clubs, :country, :string, :limit => 50)
    remove_column(:clubs, :county, :string, :limit => 50)
    #
    remove_column(:club_members, :application)
  end
end