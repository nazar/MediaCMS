class RssSubscriptionIp < ActiveRecord::Base
  belongs_to :rss_stats
  
  #class methods
  
  def self.add_stat(stat, ip_address)
    RssSubscriptionIp.create(:rss_stats_id => stat.id, :ip => ip_address)
  end
  
  def self.is_subscribed(stat, ip_address)
    RssSubscriptionIp.count(:conditions => ['rss_stats_id = ? and ip = ?', stat.id, ip_address]) > 0
  end
  
end