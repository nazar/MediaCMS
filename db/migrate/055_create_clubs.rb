class CreateClubs < ActiveRecord::Migration
  def self.up
    create_table :clubs do |t|
      t.column :user_id,      :integer
      t.column :name,          :string, :limit => 200
      t.column :description,   :text
      t.column :created_at,    :datetime
      t.column :club_type,     :integer
      t.column :members_count, :integer, :default => 0 
    end
    add_index(:clubs, :user_id)
    #
    add_column(:host_plans, :club, :integer, {:limit => 4, :default => 0})
  end

  def self.down
    drop_table :clubs
    remove_column(:host_plans, :club)
  end
end
