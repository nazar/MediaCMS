class CreateArticleRevisions < ActiveRecord::Migration
  def self.up
    create_table :article_revisions do |t|
      t.column :article_id,   :integer
      t.column :user_id,      :integer
      t.column :revision,     :integer, :default => 0
      t.column :created_at,   :datetime
    end
    add_index(:article_revisions, :article_id)
    add_index(:article_revisions, :user_id)
  end

  def self.down
    drop_table :article_revisions
  end
end
