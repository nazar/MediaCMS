class CreateFriends < ActiveRecord::Migration
  def self.up
    create_table :friends do |t|
      t.column :user_id, :integer
      t.column :friend_id, :integer
      t.column :created_at, :datetime
      t.column :comments, :string, :limit => 150
    end
    #
    add_index('friends', 'user_id')
    add_index('friends', 'friend_id')
    #finally add a friends_counts column to user for stats
    add_column('users', 'friends_count', :integer, {:default => 0})
  end

  def self.down
    drop_table :friends
    remove_column('users', 'friends_count')
  end
end
