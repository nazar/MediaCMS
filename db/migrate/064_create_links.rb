class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.column :name, :string , :limit => 200
      t.column :link, :string, :limit => 200
      t.column :descrition , :text
    end
  end

  def self.down
    drop_table :links
  end
end
