class CreateProtectorLogs < ActiveRecord::Migration
  def self.up
    create_table :protector_logs do |t|
      t.column :ip,         :string, :limit => 15
      t.column :dns,        :string, :limit => 100
      t.column :log,        :string, :limit => 100 
      t.column :created_at, :datetime
    end
    add_index(:protector_logs, :ip)
  end

  def self.down
    drop_table :protector_logs
  end
end
