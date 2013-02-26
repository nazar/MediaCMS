class Account < ActiveRecord::Base
  
  acts_as_tree :counter_cache => true 

  has_many :postings
  
  #class methods
  
  def Account.post_to_account(account, value)
    #post to this account and to any parent accounts
    account.balance += value
    account.save
    #post value to parent account for aggregates
    Account.post_to_account(account.parent, value) if account.parent
  end
  
end
