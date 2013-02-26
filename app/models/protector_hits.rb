class ProtectorHits < ActiveRecord::Base
  CRAWLTIMEOUT = 60
  CRAWLCOUNT   = 30
  #class methods
  def self.check_for_dos(request)
    t      = Time.new
    result = false
    ip     = request.remote_ip
    url    = request.request_uri
    #
    ProtectorHits.transaction do
      delete_all("expire < #{t.to_i}")
      #check against aggressive crawler
      if count_by_sql(["select count(*) from protector_hits where ip = ?",ip] ) > CRAWLCOUNT.to_i
        result = true
        ProtectorLog.log_crawler(ip)
        Ban.ban_ip_for(ip, 10.minutes, 
          'Bad or aggressive website crawler. Scrapping bots are not welcome and <b>WILL</b> be reported to your ISP')
      end
      ProtectorHits.create(:ip => ip, :url => url, :expire => t.to_i + CRAWLTIMEOUT)
    end
    #
    return result
  end
  
  #instance methods
  
end
