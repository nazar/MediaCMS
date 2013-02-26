class UpdateServerTasks < ActiveRecord::Migration
  def self.up
    add_column(:server_tasks, :taskable_type, :string, {:limit => 50})
    add_column(:server_tasks, :next_run, :datetime)
    add_column(:server_tasks, :period, :string, {:limit => 10})
    add_column(:server_tasks, :retry_period, :string, {:limit => 10})
  end

  def self.down
    remove_columm(:server_tasks, :taskable_type)
    remove_column(:server_tasks, :period)
  end
end
