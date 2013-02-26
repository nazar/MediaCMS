class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table "jobs", :force => true do |t|
      t.column "worker_class",  :string
      t.column "worker_method", :string
      t.column "args",          :text
      t.column "priority",      :integer
      t.column "progress",      :integer
      t.column "state",         :string
      t.column "lock_version",  :integer
      t.column "start_at",      :datetime
      t.column "started_at",    :datetime
      t.column "created_at",    :datetime
      t.column "updated_at",    :datetime
      t.column "result",        :text
      t.column "queue",         :string,   :limit => 10
    end

    add_index "jobs", ["state"]
    add_index "jobs", ["start_at"]
    add_index "jobs", ["priority"]
    add_index "jobs", ["created_at"]
  end

  def self.down
    drop_table :jobs
  end
end
