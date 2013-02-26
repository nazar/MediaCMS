class CreatePostings < ActiveRecord::Migration
  def self.up
    create_table :postings do |t|
      t.column :account_id,   :integer
      t.column :user_id,      :integer
      t.column :journal_id,   :integer
      t.column :our_ref,      :string, :length => 25
      t.column :their_ref,    :string, :length => 25
      t.column :created_at,   :datetime
      t.column :year,         :string, :length => 4
      t.column :month,        :string, :length => 2
      t.column :value,        :float, :default => 0
      t.column :debit_credit, :boolean, :defailt => 0
      t.column :paid,         :boolean, :default => 0
    end
    add_index(:postings, :account_id)
    add_index(:postings, :user_id)
    add_index(:postings, :journal_id)
    add_index(:postings, :our_ref)
    add_index(:postings, :their_ref)
  end

  def self.down
    drop_table :postings
  end
end
