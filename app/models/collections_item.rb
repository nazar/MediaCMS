class CollectionsItem < ActiveRecord::Base
  
  belongs_to :item, :polymorphic => true
  belongs_to :collection

  named_scope :by_object, lambda{|obj|
    {:conditions => ['item_id = ? and item_type = ?', obj.id, obj.class.name.constantize.base_class.name]}
  }

  named_scope :by_media_type, lambda{|klass|
    media_condition = klass == klass.base_class ? '' : "and medias.type = '#{klass.name}'"
    { :conditions => {:item_type => 'Media'},
      :joins => "inner join medias on medias.id = collections_items.item_id #{media_condition}",
    }
  }
  named_scope :landscape_photos,
    { :select => 'collections_items.*', 
      :conditions => {:item_type => 'Media'},
      :joins => 'inner join medias on medias.id = collections_items.item_id and medias.type = "Photo" and medias.aspect_ratio between 1 and 1.8'
    }

  #class methods

  def self.add_photo_to_collection(photo, collection)
    #add only if not already added
    if CollectionsItem.count(:conditions => ['photo_id = ? and collection_id = ?',photo.id, collection.id]) == 0
      item = collection.collections_items.create(:photo_id => photo.id)
      collection.collection_size += photo.file_size
      collection.collection_items_count += 1
      collection.save
      #
      return item
    end
  end
  
  def self.remove(item)
    collection = item.collection
    collection.collection_size -= item.item.file_size if collection.collection_size > 0
    collection.collection_items_count += -1
    collection.save
    #delete
    item.destroy
  end

  #find all Collection which contains given media in its CollectionItem. Adjust each Collection's count and size
  def self.remove_media(media)
    self.by_object(media).each do |item|
      self.remove(item)
    end
  end

  #instance methods

  #safe method to access a photo collectionable object
  def photo
    raise "Attempted to access item as photo on id #{id} when type was actually #{item.type}" unless item.is_a? Photo
    item
  end

  def item_type=(sType)
    super(sType.to_s.constantize.base_class.to_s)
  end
      
end
