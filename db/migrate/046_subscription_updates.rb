class SubscriptionUpdates < ActiveRecord::Migration
  #misc updates for subscription functionality
  def self.up
    #add field to hold paypal's subscriber_id field
    add_column(:users, :paypal_sub_id, :string, {:limit => 50})
    add_index(:users, :paypal_sub_id)
    #create cancelled/failed subs table. Store failed subs here. If client does not rectify fail/cancel 
    #change account back to free account. Could do things like delete least popular/unfavourites/unsold fotos
    create_table :subscription_failures do |t|
      t.column :user_id,              :integer
      t.column :host_plan_id,         :integer
      t.column :created_at,           :datetime
    end
    add_index(:subscription_failures, :user_id)
  end

  def self.down
    remove_column(:users, :paypal_sub_id)
    #
    drop_table(:subscription_failures)
  end
end
