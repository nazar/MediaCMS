class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table :purchases do |t|
       t.column :user_id,    :integer
       t.column :photo_id,   :integer
       t.column :journal_id, :integer
       t.column :value,      :float
       t.column :sale,       :boolean, :default => 0
       t.column :created_at, :datetime
    end
    add_index(:purchases, :user_id)
    add_index(:purchases, :photo_id)
    add_index(:purchases, :journal_id)
  end

  def self.down
    drop_table :purchases
  end
end
