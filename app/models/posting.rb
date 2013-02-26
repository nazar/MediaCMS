class Posting < ActiveRecord::Base
  belongs_to :account
  belongs_to :journal
  belongs_to :user
  belongs_to :journal
  
  #instance methods
  
  def abs_value
    return value.abs 
  end
end
