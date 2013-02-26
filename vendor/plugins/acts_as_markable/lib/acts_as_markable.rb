# ActsAsMarkable
module PSP
  module Acts #:nodoc:
    module Markable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_markable(options={})
          options[:class] ||= 'Marker'
          has_many :markers, :as => :markable, :dependent => :destroy, :class_name => options[:class]
          include PSP::Acts::Markable::InstanceMethods
          extend  PSP::Acts::Markable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods

        #returns any object that has been marked, i.e. Photo.marked
        def marked_objects
          table = self.table_name
          self.scoped(:conditions => ["#{table}.id in (select markable_id from markers where markable_type = ?)", self.base_class.name])
        end

        # Helper method to lookup for markers for a given object.
        # This method is equivalent to obj.markers.
        def find_markers_for(obj)
          markable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
         
          Marker.find(:all,
            :conditions => ["markable_id = ? and markable_type = ?", obj.id, markable],
            :order => "created_at DESC"
          )
        end
        
        # Helper class method to lookup markers for
        # the mixin markable type written by a given user.  
        # This method is NOT equivalent to marker.find_markers_for_user
        def find_markers_by_user(user) 
          markable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          
          Marker.find(:all,
            :conditions => ["user_id = ? and markable_type = ?", user.id, markable],
            :order => "created_at DESC"
          )
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        # Helper method to sort markers by date
        def markers_ordered_by_submitted
          Marker.find(:all,
            :conditions => ["markable_id = ? and markable_type = ?", id, self.type.name],
            :order => "created_at DESC"
          )
        end
        
        # Helper method that defaults the submitted time.
        def add_marker(marker)
          markers << marker
        end
      end
      
    end
  end
end
