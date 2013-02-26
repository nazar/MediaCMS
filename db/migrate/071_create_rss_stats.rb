class CreateRssStats < ActiveRecord::Migration
  def self.up
    create_table :rss_stats do |t|
      t.column :name,       :string, :limit => 50
      t.column :link_id,    :integer
      t.column :link_type,  :string, :limit => 25
      t.column :sub_count,  :integer, :default => 0
      t.column :read_count, :integer, :default => 0
    end
    add_index(:rss_stats, :link_id)
  end

  def self.down
    drop_table :rss_stats
  end
end
