class UpdateForArticles < ActiveRecord::Migration
  def self.up
    #misc updates to support articles
    #update photos to add a private flag... photos marked private will not be listed outside of my photos
    add_column(:photos, :private, :integer, {:default => 0})
    Photo.update_all('private = 0')
    #update articles for approval columns
    add_column(:articles, :approved, :integer, {:default => 0})
    add_column(:articles, :approved_date, :datetime)
    add_column(:articles, :approved_by, :integer)
    add_column(:articles, :approved_rev, :integer)
    add_column(:articles, :revs_count, :integer, {:default => 0})
    #
    add_index(:articles, :approved_by)
    #update revision to add article body
    add_column(:article_revisions, :body, :text)
  end

  def self.down
    remove_column(:photos, :private)
    remove_column(:articles, :approved);
    remove_column(:articles, :approved_date);
    remove_column(:articles, :approved_by);
    remove_column(:articles, :approved_rev);
    remove_column(:articles, :revs_count);
    remove_column(:article_revisions, :body)
  end
end
