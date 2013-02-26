class Notification < ActiveRecord::Base
  
  belongs_to :notifiable, :polymorphic => true #these are for the notification objects
  belongs_to :user
  
  #class methods
  
  def self.setup_default_notifications_for_user(user)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'System',     :event => 'newsletter', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Photo',      :event => 'comment', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Video',      :event => 'comment', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Audio',      :event => 'comment', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Article',    :event => 'comment', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Collection', :event => 'comment', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Photo',      :event => 'buy', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Video',      :event => 'buy', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Audio',      :event => 'buy', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Collection', :event => 'buy', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Photo',      :event => 'sell', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Video',      :event => 'sell', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Audio',      :event => 'sell', :enabled => true)
    Notification.create(:user_id => user.id, :notifiable_id => 0, :notifiable_type => 'Collection', :event => 'sell', :enabled => true)
  end
  
  def self.event_descriptions
    { :comment => 'Email notification when a comment is made',
      :buy     => 'Email notification when an item is bought',
      :sell    => 'Email notification when an item is sold',
      :newsletter => "Receive #{Configuration.site_name} newsletters by email"
    }
  end
  
  def self.new_comment(commented, comment, commented_link)
    #determine if user has this notification enabled
    if commented.respond_to?('user')
      if Notification.can_notify(commented.user, commented.class.to_s, 0, 'comment')
        NotificationMailer.deliver_new_comment(commented, comment, commented_link)
      end
    end  
  end
  
  def self.can_notify(user, type, type_id, event)
    Notification.count(:conditions => ["user_id = ? and notifiable_id = ? and notifiable_type = ? and event = ? and enabled = 1",
                                        user.id, type_id, type, event]) > 0
  end

  #instance methods

  def not_valid_notification_for_user(user)
    #can user sell? 
    result = (event == 'sell') && (not user.host_plan.can_sell); 
    result = result || ((notifiable_type == 'Video') && (not Configuration.module_videos));
    result = result || ((notifiable_type == 'Audio') && (not Configuration.module_audios));
    result
  end
  
end
