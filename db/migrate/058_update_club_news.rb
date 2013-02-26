class UpdateClubNews < ActiveRecord::Migration
  def self.up
    add_column(:news_items, :club_id, :integer)
    change_column(:news_items, :news_topic_id, :integer, {:null => true})
    add_index(:news_items, :club_id)
  end

  def self.down
    remove_column(:news_items, :club_id)
    change_column(:news_items, :news_topic_id, :integer, {:null => false})
    remove_index(:news_items, :club_id)
  end
end