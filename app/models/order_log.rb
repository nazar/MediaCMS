class OrderLog < ActiveRecord::Base
  belongs_to :order
  belongs_to :user
  
  #class methods
  
  def OrderLog.add_order_log(order, notify, raw_post)
    OrderLog.create( :order_id => order.id, :user_id => order.user_id, :notify_yaml => notify.to_yaml, 
                           :raw_log => raw_post)
  end
  
  def OrderLog.add_sub_log(user, notify, raw_post)
    OrderLog.create(:user_id => user.id, :notify_yaml => notify.to_yaml, :raw_log => raw_post)
  end
  
end
