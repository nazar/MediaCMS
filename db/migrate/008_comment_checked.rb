class CommentChecked < ActiveRecord::Migration
  
  #add checked comment logic to display all comments in admin until they are checked
  #from appropriatess
  
  def self.up
    add_column(:comments, :checked,  :boolean)
    add_column(:comments, :checked_at, :timestamp)
    add_column(:comments, :checked_by, :integer)
  end
  
  def self.down
    remove_column(:comments, :checked)
    remove_column(:comments, :checked_at)
    remove_column(:comments, :checked_by)
  end
  
end