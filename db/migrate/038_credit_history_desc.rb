class CreditHistoryDesc < ActiveRecord::Migration
  def self.up
    add_column(:credit_histories, :description, :string)
  end

  def self.down
    remove_column(:credit_histories, :description)
  end
end
