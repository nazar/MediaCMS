class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.column :user_id, :integer
      t.column :notifiable_id, :integer
      t.column :notifiable_type, :string, :limit => 50
      t.column :event, :string, :limit => 50
      t.column :enabled, :boolean, :default => true
    end
    add_index(:notifications, :user_id)
    add_index(:notifications, :notifiable_id)
    add_index(:notifications, [:notifiable_type,:event])
    #need to set default notifications for all existing users.
    User.transaction do
      User.find(:all, :conditions => 'activated > 0').each{|u|
        u.setup_default_notifications
      }
    end
  end

  def self.down
    remove_index(:notifications, :user_id)
    remove_index(:notifications, :notifiable_id)
    remove_index(:notifications, [:notifiable_type,:event])
    drop_table :notifications
  end
end
