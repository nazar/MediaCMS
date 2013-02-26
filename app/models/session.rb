Session = CGI::Session::ActiveRecordStore::Session
Session.class_eval do
  def self.sweep!
    delete_all ['updated_at < ?', 2.days.ago.utc]
  end
end