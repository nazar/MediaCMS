class CreateOrderLogs < ActiveRecord::Migration
  def self.up
    create_table :order_logs do |t|
      t.column :order_id,       :integer
      t.column :user_id,        :integer
      t.column :log_type,       :integer
      t.column :created_at,     :datetime
      t.column :notify_yaml,    :text
      t.column :raw_log,        :text
    end
    add_index(:order_logs, :order_id)
    add_index(:order_logs, :user_id)
  end

  def self.down
    drop_table :order_logs
  end
end
