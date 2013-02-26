class PromotionMembership < ActiveRecord::Migration
  def self.up
    add_column :promotions, :expires_at, :datetime
    #add special column to users... users set with special will not be processed for pro/prem memberships
    add_column :users, :special_member, :boolean, {:default => false}
    #set all to false
    User.update_all('special_member = 0','admin is null or admin <> 1')
  end

  def self.down
    remove_column :promotions, :expires_at
    remove_column :users, :special_member
  end
end
