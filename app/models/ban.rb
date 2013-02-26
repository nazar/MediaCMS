class Ban < ActiveRecord::Base
  
  #class methods
  
  def self.check_for_bans(request)
    t      = Time.new
    ip     = request.remote_ip
    banned = nil
    Ban.transaction do
      delete_all("expires_at < #{t.to_i}")
      #check if this IP is banned
      banned = self.find_by_ip(ip)
    end
    return banned
  end
  
  def self.ban_ip_for(ip, time, reason)
    Ban.create(:ip => ip, :reason => reason, :expires_at => time.from_now.to_i)
  end
end
