class CreateCreditHistories < ActiveRecord::Migration
  def self.up
    create_table :credit_histories do |t|
       t.column :user_id,    :integer
       t.column :journal_id, :integer
       t.column :value,      :float
       t.column :created_at, :datetime
    end
    add_index(:credit_histories, :user_id)
    add_index(:credit_histories, :journal_id)
  end

  def self.down
    drop_table :credit_histories
  end
end
