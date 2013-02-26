class AddExtraServerTask < ActiveRecord::Migration
  def self.up
    add_column(:server_tasks, :extra, :string, {:limit => 20})
    remove_column(:server_tasks, :taskable_type)
  end

  def self.down
    remove_column(:server_tasks, :extra)
    add_column(:server_tasks, :taskable_type, :string, {:limit => 50})
  end
end
