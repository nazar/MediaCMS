class DropModerationTables < ActiveRecord::Migration
  def self.up
    drop_table :moderatorships
    drop_table :monitorships
  end
  
  def self.down
    create_table "moderatorships", :force => true do |t|
      t.column "forum_id", :integer
      t.column "user_id",  :integer
    end
  
    add_index "moderatorships", ["forum_id"], :name => "index_moderatorships_on_forum_id"
  
    create_table "monitorships", :force => true do |t|
      t.column "topic_id", :integer
      t.column "user_id",  :integer
      t.column "active",   :boolean, :default => true
    end  
  end
end