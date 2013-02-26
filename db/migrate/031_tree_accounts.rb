class TreeAccounts < ActiveRecord::Migration

  def self.up
    add_column(:accounts, :parent_id, :integer)
    add_column(:accounts, :accounts_count, :integer, {:default => 0})
  end

  def self.down
    remove_column(:accounts, :parent_id)
    remove_column(:accounts, :children_count)
  end
  
end

