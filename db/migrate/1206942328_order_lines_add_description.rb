class OrderLinesAddDescription < ActiveRecord::Migration
  def self.up
		add_column(:order_items, :description, :string, {:limit => 200})
		#update description column if order already exist
		OrderItem.find(:all).each{ |item|
			case item.item_type
		  when 1
			  item.description = ""
      end
    }
  end

  def self.down
		remove_column(:order_items, :description)
  end
end
