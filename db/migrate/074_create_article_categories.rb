class CreateArticleCategories < ActiveRecord::Migration
  def self.up
    create_table :article_categories do |t|
      t.column :name,           :string,    :limit => 100
      t.column :description,    :text
      t.column :created_at,     :datetime
      t.column :articles_count, :integer, :default => 0
    end
  end

  def self.down
    drop_table :article_categories
  end
end
