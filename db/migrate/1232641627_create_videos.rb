class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.column "user_id",          :integer,                 :default => 0,    :null => false
      t.column "title",            :string,   :limit => 200, :default => "",   :null => false
      t.column "description",      :text
      t.column "text_tags",        :text
      t.column "views_count",      :integer,                 :default => 0
      t.column "comments_count",   :integer,                 :default => 0
      t.column "downloads",        :integer,                 :default => 0
      t.column "ratings_count",    :integer,                 :default => 0
      t.column "sold_count",       :integer,                 :default => 0
      t.column "previews_count",   :integer,                 :default => 0
      t.column "favourites_count", :integer,                 :default => 0
      t.column "rating_total",     :integer,                 :default => 0
      t.column "sold_value",       :float,                   :default => 0.0
      t.column "price",            :float,                   :default => 0.0
      t.column "width",            :integer
      t.column "height",           :integer
      t.column "file_size",        :integer
      t.column "filename",         :string
      t.column "created_on",       :datetime
      t.column "updated_on",       :datetime
      t.column "approved_on",      :datetime
      t.column "approved_by",      :string,   :limit => 30
      t.column "file_type",        :string
      t.column "license_id",       :integer
      t.column "private",          :integer,                 :default => 0
      t.column "approved",         :boolean,                 :default => true
      t.column "aspect_ratio",     :float
      t.column "photo_state",      :integer,                 :default => 0
      t.column "job_id",           :integer
      t.column "orig_file_ext",    :string,   :limit => 10
    end
    add_index "videos", ["user_id"]
    add_index "videos", ["title"]
    add_index "videos", ["license_id"]
    add_index "videos", ["created_on"]
  end

  def self.down
    drop_table :videos
  end
end
