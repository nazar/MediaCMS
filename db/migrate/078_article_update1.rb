class ArticleUpdate1 < ActiveRecord::Migration
  def self.up
    add_column :articles, :diggable,     :integer, {:default => 1}
    add_column :articles, :commentable,  :integer, {:default => 1}
    add_column :articles, :rateable,     :integer, {:default => 1}
    add_column :articles, :bookmarkable, :integer, {:default => 1}
    add_column :articles, :strict_revs,  :integer, {:default => 0}
    #update all articles
    Article.update_all('diggable = 1, commentable = 1, rateable = 1, bookmarkable = 1')
  end

  def self.down
    remove_column :articles, :diggable
    remove_column :articles, :commentable
    remove_column :articles, :rateable
    remove_column :articles, :bookmarkable
    remove_column :articles, :strict_revs
  end
end
