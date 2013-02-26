class CreditHistory < ActiveRecord::Base
  #credit_type: 
  #1 - Buy Credit
  #2 - Buy Photo
  #3 - Sell Photo
  #4 - sell credits
  #5 - sell license
  
  belongs_to :user
  belongs_to :journal
  
  #class methods
  
  def self.add_credit(order, journal, credit = true)
    value = credit ? order.total : -order.total
    history = CreditHistory.new( :user_id => order.user_id, :journal_id => journal.id,
                                 :order_id => order.id, :value => value,
                                 :description => 'Added credit to account', :credit_type => 1)
    history.save!
    #
    return history
  end
  
  def self.add_manual_credit(journal, amount, user, credit = true)
    value = credit ? amount : -amount
    history = CreditHistory.new( :user_id => user.id, :journal_id => journal.id, :value => value,
                                 :description => 'Manually credited account', :credit_type => 1)
    history.save!
    #
    return history    
  end
  
  def self.sell_credit(sale, journal, value)
    history = CreditHistory.new( :user_id => sale.user_id, :journal_id => journal.id,
                                 :order_id => sale.id, :value => value,
                                 :description => "Sold credits to #{Configuration.site_name}", :credit_type => 4)
    history.save!    
  end
  
  def self.photo_purchase(order, journal, item) #TODO refactor to media_purchase
    #two credit entries.. one to debit from buyer and one to credit seller (minus commission)
    value   = item.line_value
    commission = value * Configuration.sales_comission
    seller  = item.user_id_from_order_item  
    desc    = item.type_desc.downcase
    #buyer
    CreditHistory.create( :user_id => order.user_id, :journal_id => journal.id,
                                 :order_id => order.id, :value => value * -1,
                                 :description => "Bought #{desc}", :credit_type => 2 )
    #seller
    CreditHistory.create( :user_id => seller, :journal_id => journal.id,
                                 :order_id => order.id, :value => value - commission,
                                 :description => "Sold #{desc}", :credit_type => 3 )
  end
    
end
