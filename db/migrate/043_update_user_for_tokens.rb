class UpdateUserForTokens < ActiveRecord::Migration
  def self.up
    add_column(:users, :token, :string, {:limit => 10})
    add_column(:users, :activated, :boolean, {:default => false}) #set when user activates account. Can't login
    add_column(:users, :active, :boolean, {:default => false})  #to disable/ban user. Can't login
    add_column(:users, :photos_ratings_count, :integer, {:default => 0})
    #index
    add_index(:users, :token)
    #update all users for new columns
    User.find(:all).collect do |u|
      u.token     = String.random_string(10)
      u.activated = true
      u.active    = true
      u.save
    end
  end

  def self.down
    remove_column(:users, :token)
    remove_column(:users, :active)
    remove_column(:users, :activated)
    remove_column(:users, :photos_ratings_count)
  end
end
