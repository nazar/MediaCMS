class CreateBadWords < ActiveRecord::Migration
  def self.up
    create_table :bad_words do |t|
      t.column :word, :string
      t.column :replaced_count, :integer, :default => 0
      t.column :created_at, :datetime
    end
    add_index(:bad_words, :word)
  end

  def self.down
    drop_table :bad_words
  end
end
