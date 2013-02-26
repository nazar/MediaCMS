class OrderItem < ActiveRecord::Base
  #order_type 
  #1 = buy picture.. match with picture id
  #2 = buy credit... picture_id is blank
  #3 = buy collection
  #4 = buy license
  #5 = buy photo at specific resolution
  #6 = buy video
  
  belongs_to :order
  #TODO possible refactor to purchaseable
  belongs_to :photo, :foreign_key => 'item_id'
  belongs_to :video, :foreign_key => 'item_id'
  belongs_to :audio, :foreign_key => 'item_id'
  belongs_to :collection, :foreign_key => 'item_id'
  belongs_to :media_license_price, :foreign_key => 'item_id'
  belongs_to :photo_resolution_price, :foreign_key => 'item_id'  

  TypePhoto           = 1
  TypeCredit          = 2
  TypeLibrary         = 3
  TypeLicense         = 4
  TypePhotoResolution = 5
  TypeVideo           = 6
  TypeAudio           = 7
  TypeSubscription    = 10
  TypeSpace           = 11

  named_scope :media_items,
              {:conditions => "item_type in (#{OrderItem::TypePhoto}, #{OrderItem::TypeLibrary}, #{OrderItem::TypeVideo}, " <<
                              "#{OrderItem::TypeAudio}, #{OrderItem::TypePhotoResolution}, #{OrderItem::TypeLicense})"}

  #class methods

  def self.item_types
    {OrderItem::TypePhoto => 'Photo', OrderItem::TypeCredit => 'Credit', OrderItem::TypeLibrary => 'Library',
     OrderItem::TypeLicense => 'License', OrderItem::TypePhotoResolution => 'Photo Resolution', OrderItem::TypeVideo => 'Video',
     OrderItem::TypeAudio => 'Audio File', OrderItem::TypeSubscription => 'Subscription', OrderItem::TypeSpace => 'Additional Disk Space' }
  end
  
  #instance methods
  
  def line_value
    return value * qty
  end
  
  def type_desc
    OrderItem.item_types[item_type]
  end
  
  #retrieve user_id depending on what
  def user_id_from_order_item    #TODO possible refactor to purchaseable
    case item_type
      when OrderItem::TypePhoto
        photo.user_id
      when OrderItem::TypeLibrary
        collection.user_id
      when OrderItem::TypeLicense
        media_license_price.media.user_id
      when OrderItem::TypePhotoResolution
        photo_resolution_price.photo.user_id
      when OrderItem::TypeVideo
        video.user_id
      when OrderItem::TypeAudio
        audio.user_id
      else
        raise "cannot extract use from #{item_type}"
      #TODO host plan
      #TODO extra space
    end
  end
  
  def process_item_purchase(user)  #TODO possible refactor to purchaseable
    case self.item_type
    when OrderItem::TypePhoto, OrderItem::TypeVideo, OrderItem::TypeAudio #media
      Media.update_media_from_sales(self)
      Lightbox.add_to_library(self.media_from_item, user)
    when OrderItem::TypeLibrary #collection
      Collection.update_collection_from_sales(self) #update collection sales count
      Lightbox.add_to_library(self.collection, user) #add to user library
    when OrderItem::TypeLicense #license
      #license can be purchased in addition to photo.. check if photo in our collection...add if not
      unless Lightbox.media_in_user_lightbox(user, self.media_from_item)
        Media.update_media_from_sales(self)
        Lightbox.add_to_library(self.media_from_item, user)
      end
      Lightbox.add_to_library(self.media_license_price, user) 
    when OrderItem::TypePhotoResolution # resolution
      Media.update_media_from_sales(self) #each resolution counts as a separate photo sale
      Lightbox.add_to_library(self.photo_resolution_price, user)
    #TODO host plan
    #TODO extra space  
    end
  end
  
  def media_from_item   #TODO possible refactor to purchaseable
    case item_type
      when OrderItem::TypePhoto
        photo
      when OrderItem::TypeVideo
        video
      when OrderItem::TypeAudio
        audio
      when OrderItem::TypeLicense
        media_license_price.media
      when OrderItem::TypePhotoResolution
        photo_resolution_price.photo
      else
        raise "#{item_type} is not a media type"
    end
  end

  def object_from_item
    case item_type
      when OrderItem::TypePhoto
        photo
      when OrderItem::TypeLibrary
        collection
      when OrderItem::TypeLicense
        media_license_price
      when OrderItem::TypePhotoResolution
        photo_resolution_price
      when OrderItem::TypeVideo
        video
      when OrderItem::TypeAudio
        audio
      when OrderItem::TypeSubscription
        HostPlan.find_by_id(item_id)
      #TODO extra space
    end
  end
  
end
