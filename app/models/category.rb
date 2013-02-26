class Category < ActiveRecord::Base

  has_many_polymorphs :members, :from => [:medias, :photos, :videos, :audios]

  validates_presence_of :name
  
  acts_as_tree

  named_scope :all, {:order => 'name'}
  named_scope :first_category, {:conditions => 'parent_id is null', :order => 'name', :limit => 1}
  
  named_scope :top_categories, lambda{|*limit| limit = limit[0].nil? ? 10 : limit[0]
    {:conditions => 'members_count  > 0', :order => 'members_count DESC, name', :limit => limit}
  }

  #class methods

  def self.top_categories(options = {}, &block)
    options[:limit] ||= 10
    self.scope_or_yield(
            Category.scoped({:conditions => 'members_count  > 0', :order => 'members_count DESC, name'}.merge(options)),
            &block)
  end
  
  #instance methods
  
  def ancestors_name
    if parent
      parent.ancestors_name + parent.name + ':'
    else
      ""
    end
  end

  def long_name
    ancestors_name + name
  end
    
end