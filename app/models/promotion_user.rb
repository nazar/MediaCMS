class PromotionUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :photo
  
  #instance mehods
  
  def PromotionUser.add_history(promotion,user)
    history = PromotionUser.new( :promotion_id => promotion.id, 
                                 :user_id => user.id)
    history.save
  end
end
