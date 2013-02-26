# ActsAsMarkable
module PSP
  module Acts #:nodoc:
    module Favouriteable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_favouriteable
          has_many :favourites, :as => :favouriteable, :dependent => :destroy
          
          include PSP::Acts::Favouriteable::InstanceMethods
          extend  PSP::Acts::Favouriteable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        # Helper method to lookup for favourites for a given object.
        # This method is equivalent to obj.favourites.
        def find_favourites_for(obj)
          favouriteable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
         
          Favourite.find(:all,
            :conditions => ["favouriteable_id = ? and favouriteable_type = ?", obj.id, favouriteable],
            :order => "created_at DESC"
          )
        end
        
        # Helper class method to lookup favourites for
        # the mixin favouriteable type written by a given user.  
        # This method is NOT equivalent to marker.find_favourites_for_user
        def find_favourites_by_user(user) 
          favouriteable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          
          Favourite.find(:all,
            :conditions => ["user_id = ? and favouriteable_type = ?", user.id, favouriteable],
            :order => "created_at DESC"
          )
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        # Helper method to sort markers by date
        def favourites_ordered_by_submitted
          self.find(:all,
            :conditions => ["favouriteable_id = ? and favouriteable_type = ?", id, self.type.name],
            :order => "created_at DESC"
          )
        end
        
        # Helper method 
        def add_favourite(favourite)
          favourites << favourite
        end
      end
      
    end
  end
end
