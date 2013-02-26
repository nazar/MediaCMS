class NotificationMailer < ActionMailer::Base

  def new_comment(commented, comment, link)
    setup_email(commented.user)
    commented_type = commented.class.to_s.downcase
    no_notify   = "#{@body[:domain]}/notifications/disable/comment/#{commented_type}/#{commented.user.token}/0"
    @subject   += "New Comment on Your #{commented.class.to_s}"
    @body.merge!({:comment => comment, :commented => :commented, :commented_type => commented_type,
                  :link => link, :no_notify_link => no_notify})
  end
  
  
  protected
  
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = Configuration.site_admin
    @subject     = "[#{Configuration.site_name}] Notification - "
    @sent_on     = Time.now
    @body        = { :user   => user, 
                     :sig    => "<p><a href=\"#{Configuration.site_url}\">#{Configuration.site_name} Staff</a><p>",
                     :domain => Configuration.site_url }  
    @headers     = {}
    #all our emails will be in HTML
    @content_type = "text/html"
  end  
  
end