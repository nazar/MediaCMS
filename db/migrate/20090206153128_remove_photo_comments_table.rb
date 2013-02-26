class RemovePhotoCommentsTable < ActiveRecord::Migration
  def self.up
    drop_table :photo_comments
  end

  def self.down
    create_table "photo_comments" do |t|
      t.integer  "photo_id",               :default => 0, :null => false
      t.integer  "user_id"
      t.text     "comment"
      t.datetime "date"
      t.string   "ip",       :limit => 15
    end

    add_index "photo_comments", ["photo_id"], :name => "photo_id"
    add_index "photo_comments", ["user_id"], :name => "user_id"
  end
end
