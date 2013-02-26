class UpdateCategoriesForVideoAndAudio < ActiveRecord::Migration
  def self.up
    add_column :categories, :videos_count, :integer, {:default => 0}
    add_column :categories, :audios_count, :integer, {:default => 0}
  end

  def self.down
    remove_column :categories, :videos_count
    remove_column :categories, :audios_count
  end
end
