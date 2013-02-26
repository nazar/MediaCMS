class UserFileTypeDiskSpaceCounters < ActiveRecord::Migration
  def self.up
    add_column :users, :photo_space_used, :integer, {:default => 0}
    add_column :users, :video_space_used, :integer, {:default => 0}
    add_column :users, :audio_space_used, :integer, {:default => 0}
  end

  def self.down
    remove_column :users, :photo_space_used
    remove_column :users, :video_space_used
    remove_column :users, :audio_space_used
  end
end
