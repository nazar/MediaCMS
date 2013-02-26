class UserMailer < ActionMailer::Base

  def reset_password(user, token1, token2)
    setup_email(user)
    @subject    << "Password reset on your #{Configuration.site_name} account."
    @body.merge!({:token1 => token1, :token2 => token2 })     
  end
  
  def activate_account(user)
    setup_email(user)
    @subject    << "Please activate your #{Configuration.site_name} account."
  end
  
  def welcome_email(user, password)
    setup_email(user)
    @subject    << "Welcome to #{Configuration.site_name} - Account Details"
    @body.merge!({:password => user.password })
  end
  
  def purchase_receipt(user, order)
    setup_email(user)
    @subject    << 'Credits Purchase Receipt'
    @body.merge!({:order => order }) 
  end
  
  def purchase_order_receipt(user, order)
    setup_email(user)
    @subject    << 'Credits Purchase Order Receipt'
    @body.merge!({:order => order })
  end
  
  def sale_receipt(user, sale)
    setup_email(user)
    @subject    << 'Credits Sale Receipt'
    @body.merge!({:sale => sale })
  end

  def subscription_failed(user, host_plan, end_date)
    setup_email(user)
    @subject    << 'Subscription Payment Failed or Cancelled.'
    @body.merge!({:host_plan => host_plan, :end_date => Time.parse(end_date) + 7.days })
  end
  
  def new_or_modify_subscription(user, sub_type, host_plan)
    setup_email(user)
    @subject    << "#{sub_type} Subscription Instruction Received."
    @body.merge!({:host_plan => host_plan })
  end
  
  def promotion_code(promotion, user_email)
    @recipients  = "#{user_email.email}"
    @from        = Configuration.site_admin
    @subject     = "[#{Configuration.site_name}] - Ebay Winning Photo Download Instructions"
    @sent_on     = Time.now
    @body        = { :promotion => promotion,
                     :email     => user_email, 
                     :link      => "#{Configuration.site_url}/promotions/claim_code/#{user_email.token}",
                     :sig       => "<p><a href=\"#{Configuration.site_url}\">#{Configuration.site_name} Staff</a><p>",
                     :domain    => Configuration.site_url }  
    @headers     = {}
    #all our emails will be in HTML
    @content_type = "text/html"
  end
  
  def email_member(to, from, subject, msg)
    setup_email(to)
    subject      = "Message from #{Configuration.site_name} member" if !subject
    @from        = from
    @subject     = "[#{Configuration.site_name}] - #{subject}"
    @body.merge!({:msg => msg })
  end
  
  def order_complete(order)
    setup_email(order.user)
    @subject    << "Order Number #{order.id} Complete."
    @body.merge!({:order => order,  })
  end
  
  def news_to_club_members(club, news_item)
    #multiple receivers
    @bcc         = club.member_emails
    @from        = Configuration.site_admin
    @subject     = "[#{Configuration.site_name}] - #{club.name} Newsletter - #{news_item.title}"
    @sent_on     = Time.now
    @body        = { :club   => club, 
                     :body   => news_item.formatted_body,
                     :sig    => "<p><a href=\"#{Configuration.site_url}\">#{Configuration.site_name} Staff</a><p>"}  
    @headers     = {}
    @content_type = "text/html"    
  end
  
  def newsletter(news_item, member)
    no_notify   = "#{Configuration.site_url}/notifications/disable/newsletter/system/#{member.token}/0"
    @recipients  = member.email
    @from        = Configuration.site_admin
    @subject     = "[#{Configuration.site_name}] - Newsletter - #{news_item.title}"
    @sent_on     = Time.now
    @body        = { :user => member, :news_item   => news_item, :no_notify => no_notify,
                     :body        => news_item.formatted_body,
                     :sig         => "<p><a href=\"#{Configuration.site_url}\">#{Configuration.site_name} Staff</a><p>"}  
    @headers     = {}
    @content_type = "text/html"    
  end
  
  def club_application(club, member)
    setup_email(club.user)
    @subject    << "Club Membership Application Received"
    @body.merge!({:member => member, :club => club})  
  end
  
  def membership_approved(member)
    setup_email(member.user)
    @subject    << "Club Membership Application Approved"
    @body.merge!({:member => member, :club => member.club})
  end
  
  def membership_declined(member)
    setup_email(member.user)
    @subject    << "Club Membership Application Declined"
    @body.merge!({:member => member, :club => member.club})  
  end
  
  def notify_delete_photo(photo, delete_by, reason)
    setup_email(photo.user)
    @from        = delete_by.email
    @subject    += "Administrator Photo Deletion"
    @body.merge!({:photo => photo, :reason => reason})  
  end

  def notify_delete_video(video, delete_by, reason)
    setup_email(video.user)
    @from        = delete_by.email
    @subject    += "Administrator Video Deletion"
    @body.merge!({:video => video, :reason => reason})
  end

  def notify_delete_audio(audio, delete_by, reason)
    setup_email(audio.user)
    @from        = delete_by.email
    @subject    += "Administrator Video Deletion"
    @body.merge!({:audio => audio, :reason => reason})

  end
  
  def membership_expires_in_7_days(user)
    setup_email(user)
    @subject    << "Your Membership Expires in 7 Days"
  end
  
  def membership_expires_in_1_day(user)
    setup_email(user)
    @subject    << "Your Membership Expires Tomorrow!"
  end
  
  def collection_download_being_prepared(collection, user)
    setup_email(user)
    @subject << "Collection #{collection.name} is Being Prepared for Download"
    @body[:collection] = collection
  end
  
  def collection_download_ready(collection, user)
    setup_email(user)
    @subject << "Collection #{collection.name} is Ready for Download"
    @body[:collection] = collection
    @body[:link] = "#{@body[:domain]}/collections/download/#{collection.id}"
  end
  
  def photo_rejected(queue)
    setup_email(queue.approvable.user)
    @subject << "Upload Rejection"
    @body[:photo]  = queue.approvable
    @body[:reason] = queue.rejecton_reason
  end
  
  def photo_approved(queue)
    setup_email(queue.photo.user)
    @subject << "Uploaded Photo Approved"
    @body[:photo] = queue.photo
  end

  def audio_recode_complete(user)
    setup_email(user)
    @subject << "Batch Job - Audio Recode Complete"
  end

  protected
  
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = Configuration.site_admin
    @subject     = "[#{Configuration.site_name}] - "
    @sent_on     = Time.now
    @body        = { :user   => user, 
                     :sig         => "<p><a href=\"#{Configuration.site_url}\">#{Configuration.site_name} Staff</a><p>",
                     :domain => Configuration.site_url }  
    @headers     = {}
    #all our emails will be in HTML
    @content_type = "text/html"
  end  
  
end
