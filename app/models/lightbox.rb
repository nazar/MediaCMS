class Lightbox < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :link, :polymorphic => true

  named_scope :collections, :conditions => {:link_type => 'Collection'}
  named_scope :licenses, :conditions => {:link_type => 'MediaLicensePrice'}
  named_scope :medias, :conditions => {:link_type => 'Media'}
  named_scope :types_of_photo, :conditions => "link_type in ('Media', 'MediaLicensePrice' )"
  named_scope :date_desc, :order => 'created_at DESC'
  
  named_scope :by_user, lambda{|user|
    {:conditions => {:user_id => user.id}}#
  }
  
  #class methods
  
  def self.add_to_library(item, user)
    if Lightbox.count(:conditions => ['link_id = ? and user_id = ? and link_type = ?', item.id, user.id, item.class.base_class.name]) == 0
       Lightbox.create({:link_type => item.class.base_class.name, :user_id => user.id, :link_id => item.id})
    else
      false
    end
  end
  
  def self.by_lightbox(user, photo)
    Lightbox.find( :first, 
                   :conditions => ['user_id = ? and link_id = ? and link_type = ?', user.id, photo.id, 'Photo'])
  end

  def self.download_media_counters(lightbox)
    if lightbox.is_a?(Media)
      Lightbox.transaction do
        lightbox.increment_download;
        lightbox.link.increment_download
        #
        lightbox.link.save
        lightbox.save
      end
    end  
  end
  
  def self.media_in_user_lightbox (photo, user)
    self.count(:conditions => ['user_id = ? and link_id = ? and link_type = ?', user.id, photo.id, photo.class.base_class.name]) > 0
  end
  
  #instance methods
  
  def increment_download;
    self.downloaded += 1
  end
  
  def collection_download_stats
    Lightbox.transaction do
      increment_download
      self.save
      #now need to increment download of all collection photos
      collection = Collection.find(self.link_id)
      collection.increment_collection_photo_download_count
    end
  end
  
  def photo_resolution_download_stats
    Lightbox.transaction do
      increment_download
      self.save
      #increment photo download stats associated with this resolution
      self.link.photo.increment_download
      self.link.photo.save
    end
  end

  def link_type=(sType)
    super(sType.to_s.constantize.base_class.to_s)
  end
  
end
