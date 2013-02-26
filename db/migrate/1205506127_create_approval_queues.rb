class CreateApprovalQueues < ActiveRecord::Migration
  def self.up
    create_table :approval_queues do |t|
      t.column :photo_id, :integer
      t.column :uploaded_by , :integer
      t.column :approved, :boolean, :default => false
      t.column :rejecton_reason, :text
      t.column :actioned_by, :integer
      t.column :actioned_at, :datetime
      t.column :created_at, :datetime
    end
    add_index(:approval_queues, :photo_id, {:name => 'aq_photo_id'})
    add_index(:approval_queues, :uploaded_by, {:name => 'aq_uploaded_by'})
    add_index(:approval_queues, :actioned_by, {:name => 'aq_actioned_by'})
  end

  def self.down
    drop_table :approval_queues
  end
end
