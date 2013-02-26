class Collection < ActiveRecord::Base
  
  acts_as_commentable
  acts_as_rateable

  belongs_to :user

  has_many_polymorphs :items, :from => [:medias, :photos, :videos, :audios]

  validates_presence_of :name

  named_scope :with_items, :conditions => 'collection_items_count > 0'

  named_scope :latest_collections, lambda { |limit| limit ||= 10
    {:conditions => 'collection_items_count > 0', :order => 'created_at DESC', :limit => limit}
  }
  named_scope :latest_user_collections, lambda { |user, limit| limit ||= 10;
    {:conditions => ['collection_items_count > 0 and user_id = ?', user.id], :order => 'created_at DESC', :limit => limit}
  }
  named_scope :search, lambda{|search_str|
    {:conditions => ['name like ? or description like ?',"%#{search_str}%","%#{search_str}%"]}
  }
    
  #class instances

  def self.user_collections(user)
    Find(:all, :conditions => ['user_id = ?',user.id])
  end
  
  def self.update_collection_from_sales(order_item)
    col = Collection.find(order_item.item_id)
    col.sold_count += 1
    col.total_sales += order_item.line_value
    col.save
  end
  
  def self.check_hosting_plan_collection_price(user, plan)
    Collection.update_all('price = 0',['user_id = ?', user.id]) if !plan.can_sell
  end
  
  #instances methods
  
  def markup_description
    Misc.format_red_cloth(description) if description
  end
  
  def photo_markers_count
    photo_markers.count
  end
  
  def photo_markers
    MediaMarker.by_media_type_in_collection(Photo, self)
  end
  
  #TODO fix
  def photos_names
    collections_items.photos.collect{|i|i.item.title}.join(', ')
  end
  
  def increment_collection_photo_download_count
    Photo.increment_all_media_downloads_by_collection(self)
  end
  
  def update_sales_figures(qty, value)
    #update sales counters
    self.sold_count  += qty
    self.total_sales += value
    self.save
    #update all collection photos qty qty 1 and value/total_photos_in_collection
    Photo.update_sales_qty_and_value_by_collection(self, qty, value)
  end
  
  #query via sql as opposed to collection.collection_items.length, will load all items just for the count.
  def collection_items_count
    collections_items.count
  end
  
  #check if this collection is in my library
  def in_my_library(user)
    lib = Lightbox.count(:conditions => ["link_id = ? and user_id = ? and link_type = ?",self.id, user.id, 'Collection'])
    return lib > 0
  end

  def cache_file
    "#{Rails.root}/tmp/collection_cache/#{name.to_permalink}_#{collection_size.to_s}.zip"
  end
  
  #check whether the collection zip cache exists and is current in tmp
  def cache_exists_and_current
    File.exists?(cache_file)
  end

  def first_landscape_photo
    collections_items.landscape_photos.first.item unless collections_items.landscape_photos.blank?
  end

  def add_media_to_collection(in_media_ids)
    self.media_ids = media_ids +  in_media_ids
  end

  def remove_collection_items(item_ids)
    self.collections_item_ids = collections_item_ids - item_ids
  end

  def add_all_media_from_user(user)
    self.media_ids = user.medias.ids_only[0..Configuration.collection_edit_display-1].collect{|m| m.id}
  end

  def download_collection
    file_name = self.cache_file
    unless File.exists?(file_name)
      #check cache dir exists
      #collections cache doesn't exist.. check for previous versions then create
      Dir.new(File.dirname(file_name)).entries.delete_if{|x| ! (x =~ /.zip/) }.each do |file|
        File.delete(File.join(File.dirname(file_name), file)) if file.index(self.name)
      end
      #create collection cache tmp dir
      collect_cache_dir = File.join(File.dirname(file_name), File.basename(file_name, '.zip') )
      #clear it if it exists then recreate
      FileUtils.rmtree(collect_cache_dir) if File.directory?(collect_cache_dir)
      FileUtils.mkdir_p(collect_cache_dir)
      #copy collection files
      cnt = 1
      self.collections_items.all(:include => :item).each do |collection_item|
        obj = collection_item.item
        src  = obj.original_file
        dest = File.join(collect_cache_dir, "#{cnt}-#{obj.title.to_permalink}#{File.extname(obj.filename)}")
        eval("`cp #{src} \"#{dest}\"`")
        cnt += 1
      end
      #files are in tmp.. zip with 0 compression.. and ignore directories
      eval("`zip -5 -r -j #{file_name} #{collect_cache_dir}`")
      #done with tmp dir... remove it
      FileUtils.rmtree(collect_cache_dir)
    end
    return file_name, self.name.to_permalink + '.zip'
  end


    
end
