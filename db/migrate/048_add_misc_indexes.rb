class AddMiscIndexes < ActiveRecord::Migration
  def self.up
    add_index(:ratings, :rateable_id)
    add_index(:subscription_failures, :host_plan_id)
    add_index(:taggings, :taggable_id)
  end 

  def self.down
    remove_index(:ratings, :rateable_id)
    remove_index(:subscription_failures, :host_plan_id)
    remove_index(:taggings, :taggable_id)
  end
end
