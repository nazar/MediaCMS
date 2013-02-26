class DropOldTables < ActiveRecord::Migration
  def self.up
    drop_table(:photographers)
    drop_table(:photo_comments)
  end 

  def self.down
    create_table "photographers", :force => true do |t|
      t.column "user_id",         :integer,                :default => 0,  :null => false
      t.column "host_plan_id",    :integer,                :default => 0,  :null => false
      t.column "name",            :string,  :limit => 100, :default => "", :null => false
      t.column "bio",             :text
      t.column "state",           :string,  :limit => 50
      t.column "country",         :string,  :limit => 50
      t.column "disk_space_used", :integer,                :default => 0
      t.column "photos_count",    :integer,                :default => 0
    end
    create_table "photo_comments", :force => true do |t|
      t.column "photo_id", :integer,                :default => 0, :null => false
      t.column "user_id",  :integer
      t.column "comment",  :text
      t.column "date",     :datetime
      t.column "ip",       :string,   :limit => 15
    end
  end
end
