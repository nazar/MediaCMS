class Journal < ActiveRecord::Base

  has_many :postings
  has_many :subscription_histories
  has_many :credit_histories
  
  def self.manual_add_credit(user, amount)
    now       = Time.new
    Journal.transaction do
      journal = Journal.create(:journal_type => 1)
      #debit client credit account
      account   = Account.find_by_code('4100')
      journal.postings.create( :user_id => user.id, :value => amount,
                                         :account_id => account.id,
                                         :year => now.year, :month => now.month)
      Account.post_to_account(account, amount)
      #
      journal
    end
  end
  
  def self.buy_credit(order, notify) 
    now       = Time.new
    commission = notify.fee.to_f    #this is PayPal commission
    #
    Journal.transaction do
      journal = Journal.create(:journal_type => 1)
      #debit client credit account
      account   = Account.find_by_code('4100')
      journal.postings.create( :user_id => order.user_id, :value => order.total,
                                         :account_id => account.id,
                                         :year => now.year, :month => now.month)
      Account.post_to_account(account, order.total)
      #credit paypal bank account
      account = Account.find_by_code('1100')
      journal.postings.create( :value => -(order.total - commission) , :account_id => account.id,
                               :year => now.year, :month => now.month,
                               :their_ref => notify.transaction_id)
      Account.post_to_account(account, (order.total - commission))
      #credit paypal commission expense account
      account = Account.find_by_code('3100')
      journal.postings.create( :value => -commission, :account_id => account.id,
                               :year => now.year, :month => now.month,
                               :their_ref => notify.transaction_id)
      Account.post_to_account(account, commission)
      #
      journal
    end
  end
  
  def self.buy_photo(buyer, item) #TODO refactor to buy_media
    #when photo is purchased credit is transferred from buyer to seller account
    now       = Time.new
    price     = item.line_value
    commission = price * Configuration.sales_comission
    seller    = item.user_id_from_order_item
    #
    Journal.transaction do
      journal = Journal.create(:journal_type => 2)
      #credit buyer credit account
      account   = Account.find_by_code('4100')
      journal.postings.create( :user_id => buyer.id, :value => -price,
                                         :account_id => account.id,
                                         :year => now.year, :month => now.month)
      #debit seller account 
      journal.postings.create( :user_id => seller, :value => price - commission,
                                         :account_id => account.id,
                                         :year => now.year, :month => now.month)
      journal
    end
    
  end
  
  def self.pay_seller(seller, value)
    #credit seller credits account and debit paypal account
    now       = Time.new
    admin_fee = value * Configuration.withdraw_fee.to_f
    #
    Journal.transaction do
      journal = Journal.create(:journal_type => 3)
      #credit user credits account
      account   = Account.find_by_code('4100')
      journal.postings.create( :user_id => seller.id, :value => -value,
                                         :account_id => account.id,
                                         :year => now.year, :month => now.month)
      Account.post_to_account(account, -value)
      #debit withdrawl comission fee account
      account = Account.find_by_code('2100')
      journal.postings.create( :user_id => seller.id, :value => admin_fee,
                                         :account_id => account.id,
                                         :year => now.year, :month => now.month)
      Account.post_to_account(account, admin_fee)
      #debit paypal bank account
      account = Account.find_by_code('1100')
      journal.postings.create( :user_id => seller.id, :value => value - admin_fee,
                                         :account_id => account.id,
                                         :year => now.year, :month => now.month)
      Account.post_to_account(account, -(value - admin_fee))
      #
      journal
    end
  end
  
  def self.subscription_payment(user, notify)
    now = Time.now
    fee = notify.fee.to_f
    #
    Journal.transaction do
      journal = Journal.create(:journal_type => 4)
      #debit subscription profit account with subscription fee
      account   = Account.find_by_code('2200')
      posting = journal.postings.create( :user_id => user.id, :value => notify.gross,
                                         :account_id => account.id,  :their_ref => notify.transaction_id,
                                         :year => now.year, :month => now.month)
      Account.post_to_account(account, posting.value.abs)
      #credit paypal commission account account with paypal's fee
      account   = Account.find_by_code('3100')
      posting = journal.postings.create( :user_id => user.id, :value => -fee,
                                         :account_id => account.id, :their_ref => notify.transaction_id,
                                         :year => now.year, :month => now.month)
      Account.post_to_account(account, posting.value.abs)
      #credit paypal bank account with net
      account   = Account.find_by_code('1100')
      posting = journal.postings.create( :user_id => user.id, :value => -(notify.gross.to_f - fee),
                                         :account_id => account.id, :their_ref => notify.transaction_id,
                                         :year => now.year, :month => now.month)
      Account.post_to_account(account, posting.value.abs)
      #
      journal
    end
  end
  
end
