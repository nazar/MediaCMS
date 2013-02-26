class IncreaseServerTaskFieldSize < ActiveRecord::Migration
  def self.up
    change_column(:server_tasks, :task, :string, :limit => 30)
    change_column(:server_tasks, :period, :string, :limit => 60)
    add_index(:server_tasks, :next_run)
  end

  def self.down
    change_column(:server_tasks, :task, :string, :limit => 15)
    change_column(:server_tasks, :period, :string, :limit => 10)
    remove_index(:server_tasks, :next_run)
  end
end
