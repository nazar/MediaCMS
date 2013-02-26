class CreateBans < ActiveRecord::Migration
  def self.up
    create_table :bans do |t|
      t.column :ip, :string, :limit => 20
      t.column :reason, :string, :limit => 150
      t.column :expires_at, :integer
      t.column :created_at, :datetime
    end
    add_index(:bans, :ip)
  end

  def self.down
    drop_table :bans
  end
end
