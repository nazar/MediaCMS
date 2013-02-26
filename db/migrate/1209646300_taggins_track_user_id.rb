class TagginsTrackUserId < ActiveRecord::Migration
  
  def self.up
    add_column :taggings, :created_by, :integer
    #iterate through current taggings table and set created_by to equal photo.user_id
    Tagging.transaction do
      ActiveRecord::Base.connection.execute("update taggings set created_by = (select user_id from photos where photos.id = taggings.taggable_id) where taggings.taggable_type=\"Photo\"")
    end
    add_index :taggings, :created_by
  end

  def self.down
    remove_column :taggings, :created_by
  end
end
