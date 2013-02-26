module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
        def acts_as_taggable(options = {})
          write_inheritable_attribute(:acts_as_taggable_options, {
            :taggable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
            :from => options[:from]
          })
          
          class_inheritable_reader :acts_as_taggable_options

          has_many :taggings, :as => :taggable, :dependent => :destroy
          has_many :tags, :through => :taggings

          include ActiveRecord::Acts::Taggable::InstanceMethods
          extend ActiveRecord::Acts::Taggable::SingletonMethods          
        end
        
        #returns scoped list with all tags for this class
        def tags
          tagging_join = "inner join taggings on taggings.tag_id = tags.id"
          base_condition = ['taggings.taggable_type = ?', self.base_class.name]
          if self.base_class == self
            Tag.scoped(:conditions => base_condition, :joins => tagging_join)
          else
            table = self.table_name
            Tag.scoped(
              :conditions => base_condition,
              :joins => tagging_join + " inner join #{table} on #{table}.id = taggings.taggable_id and #{table}.type = '#{self.name}'"
            )
          end
        end

        #top tags for this class
        def top_tags(limit = nil)
          self.tags.scoped( :select => 'tags.name, count(tags.name) taggings_count',
                            :group => 'tags.name', :order => 'count(tags.name) DESC, tags.name', :limit => limit )
        end

        #tags by user for this class
        def tags_by_user(user)
          self.tags.scoped( :conditions => ['taggings.created_by = ?', user.id] )  
        end

        #top tags for this class by user
        def top_tags_by_user(user, limit = nil)
          self.top_tags(limit).scoped(:conditions => ['taggings.created_by = ?', user.id])
        end

        #alpha sorted top tags min max array
        def top_tags_min_max(limit = nil)
          Tag.sort_min_max_tag_list(self.top_tags(limit))
        end

      end
      
      module SingletonMethods

        def find_tagged_with(list)
          #must deal with STI and non STI tables
          unless self == self.base_class #this check for an STI table... need additional check to narrow down actual type
            extra = "and #{table_name}.type = '#{self.name}'"
          else
            extra = ''
          end
          self.scoped(
            :select => "#{self.table_name}.*",
            :joins => "inner join taggings on taggings.taggable_id = #{self.table_name}.id #{extra} and taggings.taggable_type = '#{self.base_class.name}' inner join tags on taggings.tag_id = tags.id ",
            :conditions => ['tags.name in (?)', list] 
          )
        end
      end
      
      module InstanceMethods
        
        #this method is destructive and will remove all taggable objects and recreate
        def tag_with(list)
          Tag.transaction do
            taggings.destroy_all

            Tag.parse(list).each do |name|
              if acts_as_taggable_options[:from]
                send(acts_as_taggable_options[:from]).tags.find_or_create_by_name(name).on(self)
              else
                Tag.find_or_create_by_name(name).on(self)
              end
            end
          end
        end
        
        #non destructive
        def tag_with_by_user(list, user)
          Tag.transaction do
            taggings.find_all_by_created_by(user.id).each{|tagging| tagging.destroy}
            
            Tag.parse(list).each do |name|
                taggable = Tag.find_or_create_by_name(name).on(self)
                taggable.created_by = user.id
                taggable.save
            end unless list.blank?
          end
        end
        
        def add_tag_list(list)          
          Tag.transaction do
            Tag.parse(list).each do |name|
              if acts_as_taggable_options[:from]
                send(acts_as_taggable_options[:from]).tags.find_or_create_by_name(name).on(self)
              else
                Tag.find_or_create_by_name(name).on(self)
              end
            end
          end
        end 

        def tag_list
          tags.collect { |tag| tag.name.include?(" ") ? "'#{tag.name}'" : tag.name }.uniq.join(" ")
        end
        
        def my_tags_objects(user)
          tags.by_user(user)
        end
        
        def my_tag_names(user)
          tags.by_user(user).all(:order => 'tags.name').collect{|tag| tag.name}.uniq.join(', ') if tags
        end

        #this taggable object's top tags, ie Photo.first.top_tags
        def top_tags(limit=nil)
          tag_list = Tag.top_object_tags(self).all :limit => limit
          if tag_list.length > 0
            tags, min_count, max_count = Tag.sort_min_max_tag_list(tag_list)
          else
            max_count = 0; min_count = 0; tags = [];
          end
          return tags, min_count, max_count
        end

        #return similar objects, of the class, that contain the same tags
        def similar_taggables(options = {})
          limit     = options.delete(:limit) || 0
          conditions = options.delete(:conditions)
          taggables = []
          tags.sort_by{|tag| tag.name}.each do |tag|
            taggables << tag.taggings.by_type(self.class).collect{|tagging| tagging.taggable_id}
            taggables = taggables.flatten.uniq.select{|target| target != self.id}
            if (limit > 0) && (taggables.length >= limit)
              taggables = taggables[0..limit-1]
              break
            end
          end
          self.class.to_s.constantize.scoped(:conditions => {:id => taggables}).all(:conditions => conditions)
        end
        
      end
    end
  end
end