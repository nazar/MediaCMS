class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.column :name, :string, :limit => 50
      t.column :content, :text
      t.column :content_type, :integer, :default => 0
      t.column :visible, :boolean, :default => true
      t.column :viewed, :integer, :default => 0
      t.column :updated_by, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :pages, :name
  end

  def self.down
    drop_table :pages
  end
end
