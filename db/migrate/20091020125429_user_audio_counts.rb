class UserAudioCounts < ActiveRecord::Migration

  def self.up
    add_column :users, :audios_count, :integer, {:default => 0}
  end

  def self.down
    remove_column :users, :audios_count
  end
end
