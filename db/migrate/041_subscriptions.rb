class Subscriptions < ActiveRecord::Migration
  def self.up
    add_column(:users, :last_sub_date, :datetime)
    add_column(:users, :next_sub_date, :datetime)
    add_column(:users, :total_sales, :float)
  end

  def self.down
    remove_column(:users, :last_sub_date)
    remove_column(:users, :next_sub_date)
    remove_column(:users, :total_sales)
  end
end
