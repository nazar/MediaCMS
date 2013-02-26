class ClubForums < ActiveRecord::Migration
  def self.up
    add_column(:forums, :club_id, :integer)
    add_column(:forums, :access_level, :integer)
    add_column(:forums, :created_by, :integer)
    add_column(:forums, :created_at, :datetime)
    #set club_id of existing forums to 0.. these will be global forums
    Forum.update_all("club_id=0, access_level=0")
    #new index
    add_index(:forums, :club_id)
    add_index(:forums, :created_by)
  end

  def self.down
    remove_column(:forums, :club_id)
    remove_column(:forums, :access_level)
    remove_column(:forums, :created_by)
    remove_column(:forums, :created_at)
  end
end
