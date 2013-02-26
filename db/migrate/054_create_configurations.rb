class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.column :config_key, :string, :limit => 30
      t.column :config_value, :string, :limit => 200
    end
    add_index(:configurations, :config_key)
  end

  def self.down
    drop_table :configurations
  end
end
