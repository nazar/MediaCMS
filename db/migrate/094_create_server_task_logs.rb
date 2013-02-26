class CreateServerTaskLogs < ActiveRecord::Migration
  def self.up
    create_table :server_task_logs do |t|
      t.column :server_task_id, :integer
      t.column :log,            :text
      t.column :created_at,     :datetime
    end
    add_index(:server_task_logs, :server_task_id, {:name => 'task_id'})
  end

  def self.down
    drop_table :server_task_logs
  end
end
