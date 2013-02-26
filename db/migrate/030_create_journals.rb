class CreateJournals < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.column :type,       :integer
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :journals
  end
end
