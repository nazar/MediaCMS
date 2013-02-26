class CreateLicenses < ActiveRecord::Migration
  def self.up
    create_table :licenses do |t|
      t.column :name, :string, :limit => 100
      t.column :user_id, :integer, :default => 0
      t.column :description, :text
    end
    #update host_plan table for extra column
    add_column(:host_plans, :license, :integer, {:limit => 4, :default => 0})
    add_column(:photos, :license_id, :integer)
    #finally indexes
    add_index(:licenses, :user_id)
    add_index(:photos, :license_id)
  end

  def self.down
    drop_table :licenses
    #
    remove_column(:host_plans, :license)
    remove_column(:photos, :license_id)
  end
end
