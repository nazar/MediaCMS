class Marker < ActiveRecord::Base

  belongs_to :markable, :polymorphic => true
  belongs_to :user

  after_create :increment_count
  after_destroy :decrement_count

  # Helper class method to lookup all markers assigned
  # to all markable types for a given user.
  def self.find_markers_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
  
  # Helper class method to look up all markers for 
  # markable class name and markable id.
  def self.find_markers_for_markable(markable_str, markable_id)
    find(:all,
      :conditions => ["markable_type = ? and markable_id = ?", markable_str, markable_id],
      :order => "created_at DESC"
    )
  end

  # Helper class method to look up a markable object
  # given the markable class name and id 
  def self.find_markable(markable_str, markable_id)
    markable_str.constantize.find(markable_id)
  end
    
  def user_name
    user_id > 0 ? user.login : 'anonymous'
  end

  def markable_type=(sType)
    super(sType.base_class.name)
  end

  protected

  def increment_count
    obj = Marker.find_markable(markable_type, markable_id)
    if obj && obj.respond_to?('markers_count')
      obj.markers_count +=  1
      obj.save
    end
  end

  def decrement_count
    obj = Marker.find_markable(markable_type, markable_id)
    if obj && obj.respond_to?('markers_count') && (obj.markers_count > 0)
      obj.markers_count -=  1
      obj.save    
    end
  end

    
end