class RssStat < ActiveRecord::Base

  has_many :rss_subscription_id
  
  #class methods
  
  def self.add_stat(name, link_id, ip_address)
    #try and find it..create if doesn't exist
    link_id = -1 if not link_id
    stat = RssStat.find(:first, :conditions => ['link_id = ? and link_type = ?',link_id, name])
    #create if doesn't exist
    if not stat
      stat = RssStat.new(:link_id => link_id, :link_type => name) 
      stat.save
      RssSubscriptionIp.add_stat(stat, ip_address)      
    elsif not stat.is_subscribed(ip_address)
      stat.sub_count += 1 
      RssSubscriptionIp.add_stat(stat, ip_address)      
    end
    stat.read_count += 1
    stat.save
  end
  
  #instance methods
  
  def is_subscribed(ip_address)
    RssSubscriptionIp.is_subscribed(self, ip_address)
  end
  
end
