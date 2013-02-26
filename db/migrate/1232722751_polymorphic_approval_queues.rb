class PolymorphicApprovalQueues < ActiveRecord::Migration
  def self.up
    add_column :approval_queues, :approvable_id,   :integer
    add_column :approval_queues, :approvable_type, :string, {:limit => 30}
    add_index  :approval_queues, :approvable_id
    #migrate existing data
    ApprovalQueue.update_all('approvable_id = photo_id', "approvable_type = 'Photo'")
    #finally, drop the photo_id column
    remove_column :approval_queues, :photo_id
  end

  def self.down
    create_column :photo_id, :integer
    #
    ApprovalQueue.update_all('photo_id = approvable_id')
    remove_column :approval_queues, :approvable_id
    remove_column :approval_queues, :approvable_type
  end
end
