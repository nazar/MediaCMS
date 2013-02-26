class UserCreditSaleRequests < ActiveRecord::Migration

  def self.up
    create_table :sale_orders do |t|
      t.column :user_id,              :integer
      t.column :journal_id,           :integer
      t.column :payment_due,          :datetime
      t.column :value,                :float
      t.column :paid_date,            :datetime
      t.column :paid_amount,          :float
      t.column :paypal_email,         :string, :limit => 100
      t.column :paypal_status,        :integer
      t.column :paypal_ref,           :string, :limit => 50
      t.column :paypal_responce,      :text
      t.column :paypal_responce_date, :datetime
      t.column :created_at,           :datetime
    end
    add_index('sale_orders', 'user_id')
    add_index('sale_orders', 'journal_id')
    add_index('sale_orders', 'paypal_ref')
    
    #add paypal email field to users
    add_column(:users, :paypal_email, :string, {:limit => 100})
  end

  def self.down
    drop_table :sale_queues
    remove_column(:users, :paypal_email)
  end
  
end
