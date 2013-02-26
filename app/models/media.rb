#state
#------------
# 0 - Created
# 1 - Uploaded
# 2 - Copied to Library
# 3 - Post Upload Processing Job Created
# 10- converted

class Media < ActiveRecord::Base

  require 'fileutils'

  StateCreated    = 0
  StateUploaded   = 1
  StateLibrary    = 2
  StatePostUpload = 3
  StateConverted  = 10

  acts_as_taggable
  acts_as_rateable
  acts_as_commentable
  acts_as_markable
  acts_as_favouriteable

  after_destroy :delete_data_and_files

  has_many  :library, :class_name => 'Lightbox', :as => :link, :dependent => :destroy
  has_many  :purchasing_users, :through => :library, :source => :user
  has_many  :approval_queue, :as => :approvable
  has_many  :comments, :as => :commentable

  has_many  :media_license_prices, :order => 'price ASC'
  has_many  :licenses, :through => :media_license_prices

  belongs_to :user
  belongs_to :license
  belongs_to :job

  validates_presence_of :title

  #class based named_scopes
  named_scope :photos,     :conditions => ['type = ?', 'Photo']
  named_scope :videos,     :conditions => ['type = ?', 'Video']
  named_scope :audios,     :conditions => ['type = ?', 'Audio']
  named_scope :landscape,  :conditions => 'aspect_ratio > 1'
  named_scope :portrait,   :conditions => 'aspect_ratio <= 1'
  named_scope :thumable,   :conditions => 'aspect_ratio between 1.2 and 1.4'
  named_scope :approved,   :conditions => 'approved = 1'
  named_scope :converted,  :conditions => ['state = ?', Media::StateConverted]
  named_scope :rated,      :conditions => 'rating_total > 0'
  named_scope :sold,       :conditions => 'sold_value > 0'
  named_scope :favourited, :conditions => 'favourites_count > 0'
  named_scope :commented,  :conditions => 'comments_count > 0'
  named_scope :voted,      :conditions => 'ratings_count > 0'
  named_scope :popular,    :conditions => 'views_count > 0'
  named_scope :date_desc,  :order => 'medias.created_on DESC'
  named_scope :ids_only,   :select => 'medias.id'
  named_scope :latest_first, :order => 'medias.created_on DESC'

  named_scope :tagged_by, lambda { |tag|
    { :conditions => ['medias.id in (select taggable_id from taggings where tag_id = ? and taggable_id = medias.id and taggable_type = ?)', tag.id, 'Media'] }
  }
  named_scope :tagged_by_word, lambda { |tag|
    { :conditions => ['medias.id in (select taggable_id from taggings where taggable_id = medias.id and taggable_type = ? and tag_id in (select tags.id from tags where tags.name = ?))', 'Media', tag] }
  }
  named_scope :owned_by, lambda { |user|
    { :conditions => ["user_id = ?",user.id] }
  }
  named_scope :by_club, lambda { |club|
    { :conditions => ['user_id in (select club_members.user_id from club_members where club_id = ?)',club.id] }
  }
  named_scope :by_user, lambda{|user|
    {:conditions => ['medias.user_id = ?',user.id], :include => :user}
  }
  named_scope :favourited, {
    :joins => "inner join favourites f on f.favouriteable_id = medias.id and f.favouriteable_type = '#{self.base_class.name}'"
  }
  named_scope :favourited_by, lambda{ |user|
    { :conditions => ['f.user_id = ?', user.id],
      :joins => "inner join favourites f on f.favouriteable_id = medias.id and f.favouriteable_type = '#{self.base_class.name}'"
    }
  }
  named_scope :in_collection, lambda{|collection|
    { :conditions => ['exists (select ci.item_id from collections_items ci where ci.item_id = medias.id and ci.collection_id = ? and ci.item_type = ?  )', collection.id, self.base_class.name]
    }
  }
  named_scope :by_name_or_description, lambda{|search|
    {:conditions => ['title like ? or description like ?', "%#{search}%", "%#{search}%"]}
  }
  named_scope :marked, {
    :conditions => ['exists (select markers.markable_id from markers where markers.markable_id = medias.id and markers.markable_type = ?)', self.base_class.name]
  }
  named_scope :unsorted, {
    :conditions => ['not exists (select member_id from categories_members where member_id = medias.id and member_type = ?)', 'Media']      
  }
  named_scope :categorised, lambda { |*args| category = args.length == 0 ? '' : "and category_id = #{args.first.id}"
    { :conditions => ["medias.id in (select member_id from categories_members where medias.id = member_id and member_type = ? #{category})", 'Media']}
  }
  
  #class method

  def self.latest_top_rated(limit = 5, count = 0, medias = [])
    #TODO consider paginating this
    days_step = Configuration.top_days_step
    #get top rated fotos from thirty days ago... if under limit then rerun query for 60 days and so on
    found = categorised.rated.approved.all( :conditions => ['created_on between ? and ? ',((count+1) * days_step).days.ago, (days_step * count).days.ago],
                                              :order  => 'rating_total DESC', :limit => limit )
    medias += found unless found.blank?
    #must have at least total limit medias to avoid infinite recursion
    if (medias.length < limit) && (self.categorised.rated.approved.count(:limit => limit, :select => 'id') >= limit)
      #incase none returned
      logger.warn("#{self.name}.latest_top_rated returned #{medias.length}, which is less than #{limit}. Extending to #{days_step * (count+1)} days )")
      self.latest_top_rated(limit - found.length, count+1, medias)
    else
      medias
    end
  end

  def self.most_recent(options = {})
    categorised.scoped({:order   => 'created_on DESC'}.merge(options))
  end

  def self.most_popular(options = {})
    categorised.approved.popular.scoped({:order => 'views_count DESC'}.merge(options))
  end

  def self.top_rated(options = {})
    categorised.approved.rated.scoped({:order => 'rating_total DESC'}.merge(options))
  end

  def self.most_voted(options = {})
    categorised.approved.rated.scoped({:order => 'ratings_count DESC'}.merge(options))
  end

  def self.most_talked(options = {})
    categorised.approved.commented.scoped({:order => 'comments_count DESC'}.merge(options))
  end

  def self.most_favourited(options = {})
    categorised.approved.favourited.scoped({:order => 'favourites_count DESC'}.merge(options))
  end

  def self.best_selling(options = {}, &block)
    self.scope_or_yield(
            categorised.approved.sold.scoped({:order   => 'sold_value DESC'}.merge(options)),
            &block)
  end

  def self.most_recent_in_category(category, options = {})
    categorised(category).approved.scoped({:order => 'created_on DESC'}.merge(options)) 
  end

  def self.top_rated_in_category(category, options = {})
    categorised(category).approved.rated.scoped({:order   => 'rating_total DESC'}.merge(options))
  end

  def self.most_recent_in_tag(tag, options = {})
    categorised.approved.tagged_by(tag).scoped({:order => 'created_on DESC'}.merge(options))
  end

  def self.top_rated_in_tag(tag, options = {})
    categorised.approved.rated.tagged_by(tag).scoped({:order => 'rating_total DESC'}.merge(options))
  end

  def self.most_recent_by_photographer(user, options = {})
    categorised.approved.owned_by(user).scoped({:order => 'created_on DESC'}.merge(options))
  end

  def self.top_rated_by_photographer(user, options = {})
    categorised.owned_by(user).approved.rated.scoped({:order => 'rating_total DESC'}.merge(options))
  end

  def self.latest_in_collection(collection, options = {})
    in_collection(collection).scoped({:order => 'created_on DESC'}.merge(options))
  end

  def self.medias_not_in_user_collection(user, collection, options={})
    existing_ids = collection.collections_items.by_media_type(Media).all(:select => 'collections_items.item_id').collect{|c| c.item_id}
    user_medias = user.medias.ids_only.collect{|m| m.id}
    user_medias = user_medias.reject{|m| existing_ids.include?(m)}.join(',')
    Media.scoped({:conditions => "medias.id in (#{user_medias})"}.merge(options))
  end

  def self.status_to_text(status)
    case status
      when 0
        'OK'
      when 1
        "Unsupported #{self.name} File"
      when 2
        'Out of user disk space'
      when 10
        'Fatal upload error. Please notify support.'
    end
  end


  def self.check_hosting_plan_photo_pricing(user, host_plan)
    #check if hosting plans have changed.. if so adjust photo prices accordingly.
    if user.host_plan_id != host_plan.id
      if !host_plan.can_sell
        Photo.update_all 'price = 0', ['user_id = ?',user.id]
      elsif !host_plan.can_set_price
        Photo.update_all 'price = 1', ['user_id = ?',user.id]
      end
    end
  end

  #increment all download counters for all media inside a collection
  #hacky but fast
  def self.increment_all_media_downloads_by_collection(collection)
    self.update_all( 'downloads = downloads + 1',
                      ["medias.id in (select ci.item_id from collections_items ci where ci.collection_id = ? and ci.item_id = ?)", collection.id, 'Media'])
  end

  def self.update_sales_qty_and_value_by_collection(collection, qty, value)
    photo_value = value.to_f/collection.collection_items_count.to_f
    Photo.update_all( ["sold_count = sold_count + ?, sold_value = sold_value + ?", qty, photo_value],
                      ["photos.id in (select photo_id from collections_items where collections_items.collection_id = ?)", collection.id])
  end

  def self.categorise_and_approve_media_by_id(id, params_hash, categories, user)
    media = self.find_by_id id
    media.attributes = params_hash
    media.price = 0 if media.price.blank?
    media.save
    #valid categories
    unless categories.blank? || categories[id].blank?
      media.categories = Category.find(categories[id])
      media.tag_with_by_user(params_hash[:text_tags].downcase, user) unless params_hash[:text_tags].nil?
      #check if new media require approval
      unless self.queue_new_media #subclassed method.
        media.approved    =  true
        media.approved_by =  -1
        media.approved_on =  Time.now
      else
        media.approved    =  false
      end
      #injection check... user can set any price
      unless user.host_plan.can_set_price
        media.price = Configuration.default_new_media_price if params_hash['price'] && (params_hash['price'].to_f > Configuration.default_new_media_price)
      end
      media.save
      #add to approval queue if option set
      ApprovalQueue.add_media_to_approval_queue(media) if self.queue_new_media
    else
      media.errors.add('categories')
    end
    yield media if block_given?
  end

  def self.increment_views_count(media, user)
    if user.nil? || (user && (media.user_id != user.id))
      media.views_count += 1
      media.save!
    end
  end

  #add to favourites only if it hasn't already been favourited
  def self.add_to_favourite_by_media_id_and_user(id, user)
    unless user.nil?
      if Favourite.find_favourites_for_favouriteable('Media', id).by_user(user).blank?
        media = Media.find(id)
        media.favourites.create({:user_id => user.id})
      end
    end
  end

  def self.media_markers_by_class
    Marker.scoped(:joins => "inner join medias on markable_id = medias.id and markers.markable_type = '#{self.base_class.name}' and medias.type = '#{self.name}'")
  end

  #return Lightbox object for this class
  def self.lightboxes
    Lightbox.medias.scoped(:joins => "inner join medias on lightboxes.link_id = medias.id and medias.type = '#{self.name}'")
  end

  #return Lightbox entries of MediaLicensePrice type but limit to Media decentant according to linked media type in media_license_prices
  def self.licenses
    Lightbox.licenses.scoped(:joins => "inner join media_license_prices mlp on mlp.id = lightboxes.link_id inner join medias on mlp.media_id = medias.id and medias.type = '#{self.name}' ")
  end

  def self.update_media_from_sales (item)
    media = item.media_from_item
    media.sold_count += item.qty
    media.sold_value += item.line_value
    media.save
  end

  def self.queue_new_media
    raise "called abstract method"
  end


  #instance methods
  

  def original_file
    raise "called abstract method"
  end

  def update_sales_figures(qty, value)
    self.sold_count += qty
    self.sold_value += value
  end

  def formatted_description
    Misc.format_red_cloth(description) if description
  end

  def safe_description
    desc = description
    desc = desc.gsub("'",'`')
    desc = desc.gsub("\r\n",' ')
    if desc.length > 100
      desc[0,100]+'...'
    else
      desc
    end
  end

  def safe_title
    title.to_permalink
  end

  def short_title
    out = title
    out = out[0,25] + '...' if out.length > 25
    return out
  end

  def increment_download
    self.downloads += 1
  end

  def description
    BadWord.filter_bad_words(read_attribute(:description))
  end

  def title
    BadWord.filter_bad_words(read_attribute(:title))
  end

  def is_one_of_my_licenses(license)
    raise "Expected MediaLicensePrice but got #{license.class.to_s}" unless license.is_a? MediaLicensePrice
    license.media_id == id
  end

  def can_edit(user)
    user && ( (user.id == user_id) || user.admin? )
  end

  def can_delete(user)
    user && ( (user.id == user_id) || user.admin? ) && (!(sold_count.to_i > 0))
  end

  #check if this media is in any of my collections
  def in_my_collection(user)
   collection = Media.count_by_sql(["select count(c.id) from collections c inner join collections_items ci on "+
                        "c.id = ci.collection_id and ci.item_id = ? and ci.item_type = 'Media' inner join lightboxes lb on "+
                        "c.id = lb.link_id and lb.user_id = ? and lb.link_type = 'Collection'", self.id, user.id]) > 0
   photo = Media.count_by_sql(["select count(l.id) from lightboxes l where link_id = ? and user_id = ? and link_type = ?",
                               self.id, user.id, 'Media']) > 0

   return collection || photo
  end

  def media_extension
    filename[/[\w|\W]+\.(\w+)$/,1]
  end

  def media_title_for_download
    "#{title}.#{media_extension}"
  end

  def unapprove_media(reason = nil)
    if self.class.queue_new_media
      #add or clear actioned flag to make visible in approval queue
      queue = ApprovalQueue.find_or_add_approval_queue(self)
      queue.show_in_queue
      queue.rejecton_reason = reason unless reason.blank?
      queue.save
      #
      self.approved = false
      self.approved_by =  nil
      self.approved_on =  nil
      #
      queue
    end
  end

  #callbacks
  protected

  #def self.from_options_or_default(options)
  #  options[:page]  ||= 1
  #  options[:limit] ||= Configuration.photos_in_block
  #end

  def  self.delete_files
    #abstarct
  end

  private

  def delete_data_and_files
    User.delete_media_data(self)
    #delete from favourites, use destroy for callbacks
    Favourite.destroy_all  "favouriteable_id = #{id} and favouriteable_type = 'Media'"
    #remove from all collections
    CollectionsItem.remove_media(self)
    #delete actual files
    self.delete_files #this is an abstract to override in children
  end




end
