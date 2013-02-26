class Promotion < ActiveRecord::Base
  has_many :promotion_users, :dependent => :delete_all
  has_many :users, :through => :promotion_users
  has_many :promotion_emails
  
  belongs_to :photo
  
  #class methods
  
  def self.types
    ['Photo','Collection','Membership']
  end
  
  def self.membership_promotion(code)
    Promotion.find(:first, :conditions => ['code = ? and link_type = ?',code,'Membership'])
  end
  
  #instance methods
  
  def process_token(user)
    #decrement uses count, add to child and add to user's library
#    if uses_remaining && (uses_remaining > 0)
#      uses_remaining = uses_remaining - 1 
#      self.save
#    end
    #process depending on whether it is a photo or collection
    object = self.link_object
    object.sold_count += 1
    object.save
    #raise object.to_yaml
    if object.class == Photo
      Lightbox.add_to_library(object, user)
    elsif object.class == Collection
      Lightbox.add_to_library(object, user)
    end
    #check if any credits are in promotion...add to user's account
    if self.credits > 0
      user.credits += self.credits
      user.save
    end
    PromotionUser::add_history(self, user)
    PromotionEmail::lock_email(self,user.email)
  end
  
  def process_free_membership(user)
    user.host_plan = self.host_plan
    user.last_sub_date = Time.now
    user.next_sub_date = 1.month.from_now
    user.save
    #
    self.uses_remaining += 1
    self.save
    #
    PromotionUser::add_history(self, user)
  end
  
  def valid_email(email)
    PromotionEmail::valid_email(self,email)
  end
  
  def link_object
    klass = link_type.constantize
    return klass.find(link_id)
  end
  
  def register_new_purchase(promotion_email)
    self.strict = true
    self.uses_remaining += 1
    self.save;
    #update link_object appropriatly
    object = link_object
    object.update_sales_figures(1, promotion_email.sale_value)
    object.save
    #not accounting entries as payment is handled by a third party (ie eBay in this situation)
  end
  
  def host_plan
    #only works for Mebership link_type
    if link_type == 'Membership'
      HostPlan.find(link_id)
    end
  end
  
end
