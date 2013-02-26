class SubHistoryTrans < ActiveRecord::Migration
  def self.up
    rename_column(:subscription_histories, :transaction, :order_transaction)
    change_column(:subscription_histories, :order_transaction, :string, {:limit => 50})
  end 

  def self.down
    rename_column(:subscription_histories, :order_transaction, :transaction)
    change_column(:subscription_histories, :transaction, :string, {:limit => 50})
  end
end
