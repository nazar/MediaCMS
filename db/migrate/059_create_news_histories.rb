class CreateNewsHistories < ActiveRecord::Migration
  def self.up
    create_table :news_histories do |t|
      t.column :club_id,      :integer
      t.column :user_id,      :integer
      t.column :news_item_id, :integer
      t.column :created_at,   :datetime
    end
    add_index(:news_histories, :club_id)
    add_index(:news_histories, :user_id)
    add_index(:news_histories, :news_item_id)
  end

  def self.down
    drop_table :news_histories
  end
end
