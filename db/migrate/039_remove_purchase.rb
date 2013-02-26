class RemovePurchase < ActiveRecord::Migration
  def self.up
    drop_table(:purchases)
    #
    add_column(:credit_histories, :credit_type, :integer)
  end

  def self.down
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
    #
    remove_column(:credit_histories, :credit_type)
  end
end
