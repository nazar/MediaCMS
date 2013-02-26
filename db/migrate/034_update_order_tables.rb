class UpdateOrderTables < ActiveRecord::Migration
  def self.up
    # Orders table
    add_column(:orders, :error_message, :string)
    add_column(:orders, :created_at,    :datetime)
    add_column(:orders, :updated_at,    :datetime)
    add_column(:orders, :customer_ip,   :string, {:limit => '15'})
    add_column(:orders, :address_1,     :string)
    add_column(:orders, :address_2,     :string)
    add_column(:orders, :city,          :string)
    add_column(:orders, :state,         :string, {:limit => '30'})
    add_column(:orders, :country,       :string, {:limit => '5'})
    add_column(:orders, :zip,           :string, {:limit => '20'})
    
    remove_column(:orders, :order_total)
    remove_column(:orders, :date)
    # Order Items table
    add_column(:order_items, :created_at, :datetime)
  end

  def self.down
    # Orders table
    remove_column(:orders, :error_message)
    remove_column(:orders, :created_at)
    remove_column(:orders, :updated_at)
    remove_column(:orders, :customer_ip)
    remove_column(:orders, :address_1)
    remove_column(:orders, :address_2)
    remove_column(:orders, :city)
    remove_column(:orders, :state)
    remove_column(:orders, :country)
    remove_column(:orders, :zip)
 
    add_column(:orders, :order_total, :float, {:default => 0})
    add_column(:orders, :date, :datetime)
    # Order Items table
    remove_column(:order_items, :created_at)
  end
end
