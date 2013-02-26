class Tagging < ActiveRecord::Base
  
  belongs_to :tag, :counter_cache => true
  belongs_to :taggable, :polymorphic => true

  named_scope :tagged_on, lambda {|object|
    {:conditions => ['tag_id = ? and taggable_id = ? taggable_type = ?', object.id, object.class.to_s.constantize.base_class.to_s]}
  }

  named_scope :by_type, lambda{|klass|
    {:conditions => ['taggable_type = ?', klass.to_s.constantize.base_class.to_s]}
  }

  def self.tagged_class(taggable)
    ActiveRecord::Base.send(:class_name_of_active_record_descendant, taggable.class).to_s
  end
  
  def self.find_taggable(tagged_class, tagged_id)
    tagged_class.constantize.find(tagged_id)
  end

  #instance methods

  #cater for inheritable STI table
  def taggable_type=(sType)
    super(sType.constantize.base_class.name)
  end
  
end