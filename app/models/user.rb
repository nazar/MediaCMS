class User < ActiveRecord::Base

  require 'digest/sha1'
  
  belongs_to :host_plan
  
  has_many :medias
  has_many :photos, :after_add => :add_photo, :after_remove => :remove_photo
  has_many :videos, :after_add => :add_video, :after_remove => :remove_video
  has_many :audios, :after_add => :add_audio, :after_remove => :remove_audio

  has_many :favourites
  has_many :news_items
  has_many :blogs, :order => 'created_at DESC'

  has_many :posts
  has_many :topics
  
  has_many :tokens, :class_name => :promotion_users
  has_many :promotions, :through => :promotion_users
  
  has_many :lightboxes_photos, :class_name => 'Lightbox', :foreign_key => 'link_id', :conditions => ['link_type = ?','Photo']
  has_many :library_photos, :through => :lightboxes_photos, :source => :photo
  has_many :credit_histories, :order => 'created_at DESC'
  
  has_many :carts, :class_name => 'Order', :conditions => ['status = ?',1]
  has_many :subscription_histories, :order => 'created_at DESC'
  has_many :sale_orders
  has_many :ipn_logs, :class_name => 'OrderLog'
  has_many :friends, :include => :my_friend
  has_many :friend_users, :through => :friends, :source => :my_friend
  
  has_many :licenses
  
  has_many :clubs, :order => 'name'
  has_many :club_members
  has_many :club_memberships, :through => :club_members, :source => :club, :order => 'name'
  
  has_many :collections, :order => 'name'
  
  has_many :articles, :include => :article_category
  has_many :approved_articles, :class_name => 'Article', :conditions => 'approved > 0'
  
  has_many :notifications, :order => 'notifiable_type, event'

  has_many :photo_jobs,  :through => :photos, :source => :job, :order => 'created_at ASC'
  has_many :video_jobs,  :through => :videos, :source => :job, :order => 'created_at ASC'
  has_many :audio_jobs,  :through => :audios, :source => :job, :order => 'created_at ASC'

  has_one :user_audio_preference, :dependent => :destroy #access using audio_preference instance method

  # Virtual attribute for the un-encrypted password
  attr_accessor :password, :terms, :promotion_code, :no_terms

  named_scope :activated, :conditions => ['activated = ?', true]
  named_scope :by_name, lambda{|name_or_login|
    {:conditions => ['login like ? and photos_count > 0',"%#{name_or_login}%"], :order => 'login ASC'}
  }                                                                       #TODO replace photo, video etc count with media count

  validates_presence_of     :login, :email
  validates_inclusion_of    :terms, :in => ['1'], :message => 'must be agreed', :if => :term_required? 
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of       :login, :with => /^[a-z0-9_-]+$/i, :message => 'may only contain letters (a-z), numbers (0-9), underscores (_) or dashes (-)'
  
  before_save :encrypt_password
  before_save :create_user_token
  
  attr_protected :admin, :activated, :active, :crypted_password, :salt, :token, :login, :password, :email, :paypal_email
  
  #instance methods

  def self.top_authors(options={}, &block)
    options[:limit] ||= 10
    self.scope_or_yield(
            User.scoped({:conditions => 'photos_count > 0',
                         :order => 'photos_count Desc, name'}.merge(options)),
            &block)
  end

  def self.best_authors(options={}, &block)
    options[:limit] ||= 10
    self.scope_or_yield(
            User.scoped({:conditions => 'ratings > 0', :order => 'ratings Desc, name'}.merge(options)),
            &block)
  end

  def self.most_blogged(options={}, &block)
    options[:limit] ||= 10
    self.scope_or_yield(
            User.scoped({:conditions => 'blogs_count > 0', :order => 'blogs_count DESC, name'}.merge(options)),
            &block)
  end
  
  def self.create_from_email(email)
    if email.split('@').length > 1
      username = email.split('@')[0]
      #raise username
      username = username.split('.')[0] if username.split('.').length > 1
      #check if name exists
      i = 0
      lookup = username.dup
      while User.find_by_login(lookup)
        i += 1
        lookup = username + i.to_s
      end  
      pssword = String.random_string(6)
      user = User.new
      user.setup_new_user(lookup, pssword, email)
      user.no_terms = true
      user.save!
      return user, pssword
    else
      return false
    end 
  end
  
  def self.add_credit(user, value)
    user.credits += value
    user.save
  end
  
  def self.sell_credit(user, value)
    user.credits -= value
    user.save
  end
  
  def self.buy_photo(user, item) #TODO refactor to buy_media
    #buyer
    sql = ActiveRecord::Base.connection();
    sql.update "update users set credits = #{user.credits = item.line_value} where id = #{user.id}"
    #values
    value = item.line_value
    commission = value * Configuration.sales_comission
    sale = value - commission
    #seller
    seller = User.find(item.user_id_from_order_item)
    seller.credits += sale
    seller.total_sales += sale
    seller.save
    #
    return User.find(user.id)
  end
  
  def self.find_by_md5_token(token)
    User.find_by_sql(['select * from users where md5(token) = ?',token])
  end
  
  def self.active_members
    User.find(:all, :conditions => 'activated = 1 and active = 1')
  end
  
  def self.delete_media_data(media)

    def User.get_rating(media)
      rating = 0
      count  = 0
      ratings = Rating.by_object(media)
      ratings.each{ |r|
        rating += r.rating
        count  += 1
        r.destroy
      }
      return rating, count
    end

    ##########  MAIN  ##########

    if media && media.user
      usr = media.user
      #determine class to call correct association callback
      case 
        when media.is_a?(Photo)
          usr.photos.delete(media) #release disk space from user on user callbacks
        when media.is_a?(Video)
          usr.videos.delete(media) #release disk space from user on user callbacks
        when media.is_a?(Audio)
          usr.audios.delete(media) #release disk space from user on user callbacks
        else
          raise "unrecognised media class #{media.class.to_s}"
      end
      #attempt to delete ratings and rollback ratings and count
      rating, count_rating = get_rating(media)
      if rating > 0
        usr.ratings       -= rating if usr.ratings > 0
        usr.ratings_count -= count_rating if usr.ratings_count > 0
      end
      usr.save!
    end
  end
  
  def self.subscription_payment(user, host_plan, notify)
    user.host_plan_id  = host_plan.id
    user.last_sub_date = Time.now
    user.next_sub_date = 1.month.from_now
    user.paypal_sub_id = notify.subscription_subscriber_id
    user.subscriber    = 1
    #remove any subscription email events
    user.remove_all_email_events
    #
    user.save
  end
  
  def self.subcription_cancellation(user)
    user.subscriber = 0
    user.save
  end
  
  def self.all_emails
    User.find(:all).map{|m| m.email}
  end
  
  def self.currently_online
    User.find(:all, :conditions => ["last_seen_at > ?", Time.now.utc-5.minutes])
  end
    
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end
  
  def self.unpaid_membership_expires_in_7_days
    #ignore admins and vips
    event = 'expire7'
    users = User.scoped(:select => 'users.*',
      :conditions => ['(admin is null or admin <> 1) and (vip <> 1) ' <<
                      'and next_sub_date < ? and subscriber = 0 ' <<
                      'and ((not (sent_email_event like ?)) or (sent_email_event is null) )', 
                    7.day.from_now, "%#{event}%"],
      :joins => 'inner join host_plans hp on users.host_plan_id = hp.id and hp.monthly_fee > 0' )
    return users, event            
  end
  
  def self.unpaid_membership_expires_in_1_day
    #ignore admins and vips
    event = 'expire1'
    users = User.scoped(:select => 'users.*',
      :conditions => ['(admin is null or admin <> 1) and (vip <> 1) ' <<
                      'and next_sub_date < ? and subscriber = 0  ' <<
                      'and ((not (sent_email_event like ?)) or (sent_email_event is null) )', 
                    36.hours.from_now, "%#{event}%"],
      :joins => 'inner join host_plans hp on users.host_plan_id = hp.id and hp.monthly_fee > 0' )
    return users, event                
  end
  
  #add periodic email notification for this user
  def self.add_email_event(user, event)
    if user.sent_email_event && user.sent_email_event.length > 0
      events = YAML::load( user.sent_email_event )
    else
      events = []
    end      
    events << event if not events.include?(event)
    user.sent_email_event = events.to_yaml #YAML::dump( test_obj )
    user.save
  end
  
  #remove periodic email notification for this user
  def self.remove_email_event(user, event)
    if user.sent_email_event && user.sent_email_event.length > 0
      events = YAML::load( user.sent_email_event )
      if events.delete(event) 
        user.sent_email_event = events.to_yaml #YAML::dump( test_obj )
        user.save
      end
    end
  end

  #optimised method to return user avatar by id
  def self.avatar_path(user, full_path = false)
    user_id = user.is_a?(User)? user.id : user 
    avatar_file = "/library/avatars/#{user_id}/#{user_id}.jpg"
    full_file   = File.join(Rails.root, 'public', avatar_file)
    if File.exists?(full_file) || full_path
      file = avatar_file
    else
      file = "/library/avatars/no_avatar.gif"
    end
    full_path ? File.join(Rails.root, 'public', file) : file
  end


  #instance methods

  
  def latest_photo_comments(limit = 5)
    Comment.by_user(self).by_media_type(Photo).all :include => :commentable, :limit => limit
  end

  def formatted_bio
    Misc.format_red_cloth(bio)
  end 
  
  def sync_user_photo_counts
    sql = "update users set photos_count    = (select count(id) from medias where medias.user_id = #{self.id})"
    self.connection.update(sql)
    sql = "update users set disk_space_used = (select sum(file_size) from medias where medias.user_id = #{self.id})"
    self.connection.update(sql)
  end
  
  def user_markers_by_media_type(type)
    Marker.scoped(:conditions => ['markers.user_id = ? and markers.markable_type = ?',id,'Media'],
           :joins => "inner join medias on markable_id = medias.id and medias.type = '#{type.name}'")
  end

  def photo_markers
    user_markers_by_media_type(Photo).all
  end

  def photo_markers_count
    user_markers_by_media_type(Photo).count
  end

  def video_markers
    user_markers_by_media_type(Video).all
  end

  def video_markers_count
    user_markers_by_media_type(Video).count
  end

  def audio_markers
    user_markers_by_media_type(Audio).all
  end

  def audio_markers_count
    user_markers_by_media_type(Audio).count
  end

  def collections_count
    Collection.count(:conditions => ['user_id = ?',id])
  end

  def total_files_count
    photos_count.to_i + videos_count.to_i #+ audios_count.to_i
  end
  
  def average_rating
    ratings / ratings_count if ratings_count > 0
  end
  
  def mycomments
    Comment.find_comments_by_user(current_user) if current_user
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save
  end
  
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save
  end
  
  def pretty_name
    if name?
      name
    else
      login
    end
  end
  
  def login_safe
    login.gsub(' ','+')
  end
  
  def rank
    if admin?
      'Administrator'
    else
      "#{host_plan.name} member"
    end 
  end
  
  def default_upload_license
    if host_plan.can_sell
      Configuration.standard_license
    else
      Configuration.free_license
    end  
  end
  
  def latest_photos(limit = 10)
    Photo.most_recent_by_photographer(self, :limit => limit)
  end
  
  #setup default notifications for a user... called when user first created
  def setup_default_notifications
    #system wide notifications
    Notification.setup_default_notifications_for_user(self)
  end
  
  def remove_all_email_events
    self.sent_email_event = ''
  end
  
  def bio
    BadWord.filter_bad_words(read_attribute(:bio))
  end
  
  def billing_address_nice
    if billing_address
      billing_address.gsub(/\n/,', ')
    end
  end

  #setup defaults for a newly created user
  def setup_new_user(login, password, email)
    self.login = login
    self.email = email
    self.host_plan = HostPlan::defaultPlan
    self.password  = password
    self.password_confirmation = password
  end

  def activate_user
    self.activated = true
    self.active    = true
    self.setup_default_notifications
  end

  def audio_preferences
    unless user_audio_preference.blank?
      prefs = user_audio_preference
    else
      prefs = build_user_audio_preference
      prefs.bitrate       = Configuration.preview_audio_bitrate
      prefs.sample_length = Configuration.preview_audio_length
      prefs.free_full_length = Configuration.audio_free_full_preview
    end
    prefs
  end

  
  protected


  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("+--#{Time.now.to_s}-+-#{login}--+") if new_record?
    self.crypted_password = encrypt(password)
  end

  def create_user_token
    return unless token.blank?
    self.token = String.random_string(10) #TODO check token doesn't exist
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def term_required?
    return false if no_terms
    new_record?
  end

  #callbacks

  def add_audio(audio)
    self.audios_count     += 1
    self.disk_space_used  += audio.file_size
    self.audio_space_used += audio.file_size
    save!
  end

  def remove_video(video)
    self.audios_count     -= 1 if self.audios_count > 0
    self.disk_space_used  -= video.file_size if ((self.disk_space_used - video.file_size) >= 0)
    self.audio_space_used -= video.file_size if ((self.audio_space_used - video.file_size) >= 0)
    save!
  end

  def add_video(video)
    self.videos_count     += 1
    self.disk_space_used  += video.file_size
    self.video_space_used += video.file_size
    save!
  end

  def remove_video(video)
    self.videos_count     -= 1 if self.videos_count > 0
    self.disk_space_used  -= video.file_size if ((self.disk_space_used - video.file_size) >= 0)
    self.video_space_used -= video.file_size if ((self.video_space_used - video.file_size) >= 0)
    save!
  end

  def add_photo(photo)
    self.photos_count     += 1
    self.disk_space_used  += photo.file_size
    self.photo_space_used += photo.file_size
    save!
  end

  def remove_photo(photo)
    self.photos_count     -= 1 if self.photos_count > 0
    self.disk_space_used  -= photo.file_size if ((self.disk_space_used - photo.file_size) >= 0)
    self.photo_space_used -= photo.file_size if ((self.photo_space_used - photo.file_size) >= 0)
    save!
  end
  
end
