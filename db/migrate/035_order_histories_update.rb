class OrderHistoriesUpdate < ActiveRecord::Migration
  def self.up
    add_column(:credit_histories, :order_id, :integer)
    add_index(:credit_histories, :order_id)
  end

  def self.down
    remove_column(:credit_histories, :order_id, :integer)  
  end
end
