class SubscriptionHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :journal
  
  #class methods
  
  def SubscriptionHistory.subscription_payment(user, journal, notify)
    SubscriptionHistory.create(:user_id => user.id, 
                 :journal_id => journal.id, :order_transaction => notify.transaction_id,
                 :value => notify.gross)
  end
end
