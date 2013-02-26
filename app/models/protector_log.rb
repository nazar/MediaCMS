class ProtectorLog < ActiveRecord::Base
  
  #class methods
  
  def self.log_crawler(ip)
    #check if logged for today before login again
    if !self.find(:first, :conditions => ['ip = ? and created_at < ?', ip, Time.now + 1.hour])
      a = Socket.gethostbyname(ip)
      res = Socket.gethostbyaddr(a[3], a[2])
      #
      ProtectorLog.create(:ip => ip, :dns => res[0], :log => 'Bad Crawler')
    end
  end
  
  
end
