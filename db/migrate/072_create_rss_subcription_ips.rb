class CreateRssSubcriptionIps < ActiveRecord::Migration
  def self.up
    create_table :rss_subscription_ips do |t|
      t.column :rss_stats_id,     :integer
      t.column :ip,               :string, :limit => 15
      t.column :created_at,       :datetime
    end
    add_index(:rss_subscription_ips, :rss_stats_id)
    add_index(:rss_subscription_ips, :ip)
  end

  def self.down
    drop_table :rss_subscription_ips
  end
end
