class Rating < ActiveRecord::Base

  belongs_to :rateable, :polymorphic => true
  belongs_to :user

  named_scope :by_object, lambda{|obj|
    {:conditions => ['rateable_id = ? and rateable_type = ?', obj.id, obj.class.to_s.constantize.base_class.to_s]}
  }

  named_scope :by_user, lambda{|user|
    {:conditions => ['user_id = ?', user.id], :order => 'created_at DESC'}
  }

  #class methods
  
  # Helper class method to look up a rateable object
  # given the rateable class name and id 
  def self.find_rateable(rateable_str, rateable_id)
    rateable_str.constantize.find(rateable_id)
  end

  #instance methods

  def rateable_type=(sType)
    super(sType.constantize.base_class.name)
  end

end