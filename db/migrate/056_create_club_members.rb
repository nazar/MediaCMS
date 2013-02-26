class CreateClubMembers < ActiveRecord::Migration
  def self.up
    create_table :club_members do |t|
      t.column :club_id,       :integer
      t.column :user_id,       :integer
      t.column :member_title,  :string, :limit => 200
      t.column :created_at,    :datetime
      t.column :status,        :integer, :default => 0
      t.column :status_date,   :datetime
    end
    add_index(:club_members, :club_id)
    add_index(:club_members, :user_id)
  end

  def self.down
    drop_table :club_members
  end
end
