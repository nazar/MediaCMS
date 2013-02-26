class CreateServerTasks < ActiveRecord::Migration
  def self.up
    create_table :server_tasks do |t|
      t.column :task,         :string, :limit => 15
      t.column :taskable_id,  :integer
      t.column :completed,    :boolean, :default => false
      t.column :completed_at, :datetime
      t.column :created_at,   :datetime
      t.column :log,          :text
    end
    add_index(:server_tasks, :taskable_id, :name => 'i_taskable_id')
  end

  def self.down
    drop_table :server_tasks
  end
end
