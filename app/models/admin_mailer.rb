class AdminMailer < ActionMailer::Base

  def alert_sub_failure(user, raw_detail)
    setup_email(user)
    @subject    += 'IPN Subscription Failure/Cancellation'
    @body        = @body.merge({:error => raw_detail})
  end
  
  def alert_unhandled_sub_ipn(user, raw_detail)
    setup_email(user)
    @subject    += 'Unhandled IPN Post' 
    @body        = @body.merge({:error => raw_detail})
  end
  
  def new_sub_or_modify(user, sub_type, raw_detail)
    setup_email(user)
    @subject    += "#{sub_type} Subscription Request" 
    @body        = @body.merge({:error => raw_detail})
  end
  
  def subscription_eot(user, raw_detail)
    setup_email(user)
    @subject    += "#{Configuration.site_name} Admin - Subscription EOT" 
    @body        = @body.merge({:error => raw_detail})  
  end
  
  def ipn_cancellation(order, raw_detail)
    setup_email(order)
    @subject    += "#{Configuration.site_name} Admin - IPN Chargeback" 
    @body        = @body.merge({:error => raw_detail})  
  end
  
  def payment_request(user, sale)
    setup_email(user)
    @subject    += "#{Configuration.site_name} Admin - Credit Withdrawl Request" 
    @body        = @body.merge({:sale => sale})  
  end
  
  def new_user(user)
    setup_email(user)
    @subject    += "#{Configuration.site_name} Admin - New User" 
  end
  
  def contact_us(params, remote_ip)
    @recipients  = Configuration.site_admin
    @from        = params[:email] ? params[:email] : Configuration.site_admin
    @subject     = "[#{Configuration.site_name} Admin] - Contact Us"
    @sent_on     = Time.now
    @body        = { :name       => params[:name],
                     :email      => params[:email],
                     :subject    => params[:subject],
                     :message    => params[:message], 
                     :ip_address => remote_ip,
                     :sig => "<p><a href=\"#{Configuration.site_url}\">#{Configuration.site_name} Staff</a><p>",
                     :domain => Configuration.site_url }  
  end
  
  def image_reported(photo)
    setup_email(Configuration.site_admin)
    @subject    = "[#{Configuration.site_name} Admin] - Image Reported - #{photo.id} - #{photo.title}"
    @body.merge!({:photo => photo})      
  end
  
  def purchase_order_placed(user, order)
    setup_email(Configuration.site_admin)
    @subject     = "[#{Configuration.site_name} Admin] - New Purchase Order"
    @body.merge!(:order => order, :user => user)
  end
  


  protected
  
  def setup_email(user)
    @recipients  = Configuration.site_admin
    @from        = Configuration.site_admin
    @subject     = "[#{Configuration.site_name} Admin] - "
    @sent_on     = Time.now
    @body        = { :user => user, 
                     :sig => "<p><a href=\"#{Configuration.site_url}\">#{Configuration.site_name} Staff</a><p>",
                     :domain => Configuration.site_url }  
    @headers     = {}
  end
   
end