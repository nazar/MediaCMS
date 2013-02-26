class UpgradeOrdersForInvoices < ActiveRecord::Migration
  def self.up
    add_column :orders, :purchase_order, :string, {:limit =>  100}
    add_column :orders, :address, :text
    #update users column to add company
    add_column :users, :company, :string, {:limit => 100}
  end

  def self.down
    remove_column :orders, :purchase_order
    remove_column :orders, :address
    #
    remove_column :users, :company
  end
end
