class CreateCategoryMembers < ActiveRecord::Migration
  def self.up
    create_table :categories_members do |t|
      t.integer :category_id, :member_id
      t.string :member_type, :limit => 50
      t.timestamps
    end
    add_index :categories_members, :category_id
    add_index :categories_members, :member_id

    #migrate existing photo, video and audio categories
    ActiveRecord::Base.connection.execute('insert into categories_members (category_id, member_id, member_type) select category_id, photo_id, "Media" from categories_photos')
    ActiveRecord::Base.connection.execute('insert into categories_members (category_id, member_id, member_type) select category_id, video_id, "Media" from categories_videos')
    ActiveRecord::Base.connection.execute('insert into categories_members (category_id, member_id, member_type) select category_id, audio_id, "Media" from categories_audios')

    #drop categories_audios, categories_photos and categories_videos
    AudioCategories::down
    VideoCategories::down
    UpdateCategoriesForVideoAndAudio::down
    drop_table :categories_photos
  end

  def self.down
    drop_table :categories_members
    #build categories_audios, categories_photos and categories_videos
    AudioCategories::up
    VideoCategories::up
    UpdateCategoriesForVideoAndAudio::up
  end
end
