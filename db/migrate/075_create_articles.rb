class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.column :user_id,               :integer
      t.column :article_category_id,   :integer
      t.column :title,                 :string, :limit => 200
      t.column :reads_count,           :integer, :default => 0
      t.column :comments_count,        :integer, :default => 0
      t.column :ratings_count,         :integer, :default => 0
      t.column :rating_total,          :integer, :default => 0
      t.column :created_at,            :datetime
      t.column :active,                :integer, :default => 1
    end
    add_index(:articles, :user_id)
    add_index(:articles, :article_category_id)
  end

  def self.down
    drop_table :articles
  end
end
