class CreateProtectorHits < ActiveRecord::Migration
  def self.up
    create_table :protector_hits do |t|
      t.column :ip,         :string, :limit => 15
      t.column :url,        :string, :limit => 50
      t.column :expire,     :integer
      t.column :created_at, :datetime
    end
    add_index(:protector_hits, :ip)
    add_index(:protector_hits, :url)
    add_index(:protector_hits, :expire)
  end

  def self.down
    drop_table :protector_hits
  end
end
