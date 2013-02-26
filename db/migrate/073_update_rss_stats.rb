class UpdateRssStats < ActiveRecord::Migration
  def self.up
    remove_column(:rss_stats, :name)
  end

  def self.down
    add_column(:rss_stats, :name, :string, {:limit => 50})
  end
end
