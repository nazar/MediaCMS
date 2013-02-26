class UserVideoCount < ActiveRecord::Migration
  def self.up
    add_column :users, :videos_count, :integer, {:default => 0}
  end

  def self.down
    remove_columne :users, :videos_count
  end
end
