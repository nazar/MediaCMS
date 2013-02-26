class DropAudios < ActiveRecord::Migration
  def self.up
    CreateAudios.down
  end

  def self.down
    CreateAudios.up
  end
end
