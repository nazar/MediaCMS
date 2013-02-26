class NotificationsController < ApplicationController

  before_filter :login_required, :except => [ :disable ]

  def disable
    #check if the user can be found
    user = User.find_by_token(params[:token])
    if user
      notify = Notification.find(:first,
                                 :conditions => ["user_id = ? and notifiable_id = ? and notifiable_type = ? and event = ?",
                                                 user.id, params[:id], params[:type].capitalize, params[:event]])
      if notify
        notify.enabled = false
        notify.save
        step_notice('Notification option updated.')
      else
        invalid_request
      end
    else
      #tarpit
      sleep(5)      
      invalid_request
    end
  end
  
  def update
    Notification.transaction do
      for notify in params[:note]
        Notification.update(notify.first, {:enabled => notify.last.to_i > 0 ? 1 : 0})
      end
    end
    redirect_to :action => :my_notifications
  end

  def my_notifications
    @page_title = 'My Notifications'
  end
  
  protected
  
  def invalid_request
    step_notice('Invalid Request')
  end
  
  
end
