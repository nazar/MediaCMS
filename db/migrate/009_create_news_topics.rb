class CreateNewsTopics < ActiveRecord::Migration
  def self.up
    create_table :news_topics do |t|
      t.column :name, :string
      t.column :description, :text
    end
  end

  def self.down
    drop_table :news_topics
  end
end
