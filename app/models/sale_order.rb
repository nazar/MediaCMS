class SaleOrder < ActiveRecord::Base
  belongs_to :journals
  belongs_to :users
  
  #class methods
  
  def SaleOrder.create_order(journal, user, value)
    pay_due = Configuration.payment_days.to_i.days.from_now
    order = SaleOrder.create( :journal_id => journal.id, :user_id => user.id, :value => value,
                              :payment_due => pay_due )
    return order
  end
  
end
