class UsersMoreCompanyInfo < ActiveRecord::Migration
  def self.up
    add_column :users, :contact_name, :string, {:limit => 100}
    add_column :users, :contact_number, :string, {:limit => 100}
    #add billing address to users as well
    add_column :users, :billing_address, :text
  end

  def self.down
    remove_column :users, :contact_name
    remove_column :users, :contact_number
    remove_column :users, :billing_address
  end
end
