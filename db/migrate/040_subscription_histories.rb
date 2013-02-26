class SubscriptionHistories < ActiveRecord::Migration
  def self.up
    create_table :subscription_histories do |t|
       t.column :user_id,     :integer
       t.column :journal_id,  :integer
       t.column :transaction, :string, :limit => 50
       t.column :value,       :float
       t.column :created_at,  :datetime
    end
    add_index(:subscription_histories, :user_id)
    add_index(:subscription_histories, :journal_id)
    add_index(:subscription_histories, :transaction)
  end

  def self.down
    drop_table(:subscription_histories)
  end
end
