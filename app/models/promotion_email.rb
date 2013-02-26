require 'digest/sha1'

class PromotionEmail < ActiveRecord::Base
  belongs_to :promotion
  
  #class methods
  
  def self.lock_email(promotion, email)
    rec = PromotionEmail.find(:first, :conditions => ["promotion_id = ? and email = ?",promotion.id, email])
    if rec
      rec.claimed_date = Time.new
      rec.save
    end
  end

  def self.valid_email(promotion, email)
    return count('id', :conditions => ["promotion_id = ? and email = ? and claimed_date is null", promotion.id, email ]) > 0
  end
  
  def self.create_and_link(promotion, email)
   obj = promotion.promotion_emails.build(email)
   obj.token = Digest::SHA1.hexdigest("#{email}/#{promotion.id}--#{Time.now}")
   obj.save
   return obj
  end
  
  #instance
  
  
end
