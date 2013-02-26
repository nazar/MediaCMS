class CreateNewsItems < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.column :news_topic_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :title, :string, :null => false
      t.column :created_at, :datetime
      t.column :body, :text, :null => false
      t.column :extra, :text
      t.column :expires, :datetime
      t.column :read, :integer, :default => 0
    end
  end

  def self.down
    drop_table :news_items
  end
end
