class CreateComments < ActiveRecord::Migration

  def self.up
    create_table :comments do |t|
      t.column :title, :string, :limit => 50, :default => ""
      t.column :comment, :string, :default => ""
      t.column :created_at, :datetime, :null => false
      t.column :commentable_id, :integer, :default => 0, :null => false
      t.column :commentable_type, :string, :limit => 15,
        :default => "", :null => false
      t.column :user_id, :integer, :default => 0, :null => false
      t.column :ip, :string, :limit =>15
      t.column :dns, :string
    end
  end
  
  def self.down
    drop_table :comments
  end
  
end