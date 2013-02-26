class VipUsers < ActiveRecord::Migration
  def self.up
    add_column(:users, :vip, :boolean, {:default => false})
    add_column(:users, :subscriber, :boolean, {:default => false})
    add_column(:users, :sent_email_event, :string, {:limit => 250})
    add_index(:users, :next_sub_date)
    #
    User.update_all('vip = 0, subscriber = 0')
  end

  def self.down
    remove_column(:users, :vip)
    remove_column(:users, :subscriber)
    remove_column(:users, :sent_email_event)
    remove_index(:users, :next_sub_date)
  end
end
