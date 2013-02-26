class SubscriptionFailure < ActiveRecord::Base
  belongs_to :user
  
  #class methods
  
  def SubscriptionFailure.capture_failure(user, host_plan, end_date)
    #check if record already exists for this user.. if not create then email
    if SubscriptionFailure.count(:conditions => ['user_id = ?', user.id]) == 0
      fail = SubscriptionFailure.create( :user_id => user.id, 
                                         :host_plan_id => host_plan.id,
                                         :created_at   => end_date)
      #notify client
      UserMailer::deliver_subscription_failed(user, host_plan, end_date)
    else
      #update created on timestamp
      fail = SubscriptionFailure.find(:first, :conditions => ['user_id = ?',user.id])
      if fail
        fail.created_at = Time.now
        fail.host_plan_id = host_plan.id
        fail.save
      end
    end
  end
  
  def SubscriptionFailure.clear_failure(user)
    SubscriptionFailure.delete_all ['user_id = ?',user.id]
  end
  
end
