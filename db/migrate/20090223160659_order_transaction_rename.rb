class OrderTransactionRename < ActiveRecord::Migration

  #Rails 2.1.2 doesn't like a column being named 'transaction'
  def self.up
    rename_column(:orders, :transaction, :gate_transaction)
  end

  def self.down
    rename_column(:orders, :gate_transaction, :transaction)
  end
end
