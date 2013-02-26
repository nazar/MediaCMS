class FixVideoTable < ActiveRecord::Migration
  def self.up
    rename_column(:videos, :photo_state, :video_state)
    add_column :videos, :duration, :integer, {:default => 0}
  end

  def self.down
    rename_column(:videos, :video_state, :photo_state )
    remove_column :videos, :duration
  end
end
