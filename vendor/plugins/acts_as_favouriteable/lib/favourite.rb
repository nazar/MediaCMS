class Favourite < ActiveRecord::Base

  belongs_to :favouriteable, :polymorphic => true
  belongs_to :user

  named_scope :by_user, lambda{|user|
    {:conditions => ['user_id = ?', user.id]}
  }
  named_scope :find_favourites_for_favouriteable, lambda{|klass, id|
    {
      :conditions => ["favouriteable_id = ? and favouriteable_type = ?", id, klass],
      :order => "created_at DESC"
    }
  }

  after_create :increment_count
  after_destroy :decrement_count
  
  # Helper class method to look up a favouriteable object
  # given the favouriteable class name and id 
  def self.find_favouriteable(favouriteable_str, favouriteable_id)
    favouriteable_str.constantize.find(favouriteable_id)
  end

  #instance methods

  def favouriteable_type=(sType)
    super(sType.constantize.base_class.name)
  end

  private

  def increment_count
    obj = Favourite.find_favouriteable(favouriteable_type, favouriteable_id)
    if obj && obj.respond_to?('favourites_count=')
      obj.favourites_count +=  1
      obj.save
    end
  end

  def decrement_count
    obj = Favourite.find_favouriteable(favouriteable_type, favouriteable_id)
    if obj && obj.respond_to?('favourites_count=')
      obj.favourites_count -=  1
      obj.save
    end
  end

      
end