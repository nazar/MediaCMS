class CommentToBody < ActiveRecord::Migration
  def self.up
    rename_column(:comments, :comment, :body)
    change_column(:comments, :body, :text)
  end 

  def self.down
    rename_column(:comments, :body, :comment)
    change_column(:comments, :comment, :string, {:limit => 255})
  end
end
