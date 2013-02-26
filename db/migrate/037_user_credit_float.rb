class UserCreditFloat < ActiveRecord::Migration
  def self.up
    change_column(:users, :credits, :float, {:default => 0})
  end

  def self.down
    change_column(:users, :credits, :integer, {:default => 0})
  end
end
