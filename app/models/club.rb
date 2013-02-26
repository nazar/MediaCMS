class Club < ActiveRecord::Base
  
  #ticket #42 - add tag support to clubs/groups
  acts_as_taggable

  #club_type : 0 - free for all, 1 - by invitiation/application
  belongs_to :user
  
  has_many :news_items, :as => :itemable, :order => 'created_at DESC'
  has_many :news_histories, :order => 'created_at DESC'
  has_many :club_members
  has_many :active_club_members, :class_name => 'ClubMember', :include => :user, :conditions => 'status > 1'
  has_many :applying_club_members, :class_name => 'ClubMember', :include => :user, :conditions => 'status = 0'
  has_many :users, :through => :club_members
  has_many :forums, :order => 'position'
   
  validates_presence_of :name, :description

  after_destroy :destroy_dependancies
  
  #class methods
  
  #my clubs
  def self.user_owner_clubs(user)
    Club.find(:all, :conditions => ['user_id = ?',user.id])
  end
  
  def self.club_types
    [[0,'Open to All'],[1,'Invitation/Application']]
  end
  
  def self.best_photos(club, options = {})
    from_options_or_default(options)
    Photo.categorised.approved.by_club(club).paginate :order => 'rating_total DESC' , :per_page => options[:limit], :page => options[:page]
  end
  
  def self.latest_photos(club, options = {})
    Photo.categorised.approved.by_club(club).paginate :order => 'created_on DESC', :per_page => options[:limit], :page => options[:page]
  end
  
  #find all clubs with forums
  def self.clubs_with_forums
    Club.find(:all, :conditions => ["id in (select club_id from forums where forums.club_id > 0)"], :order => 'name')
  end
  
  def self.clubs_tagged_with(tag)
    find_tagged_with(tag.name)
  end
    
  #instance methods
  
  def excerpt #TODO remove... model shouldn't be doing this
    description.length > 0 ? description[0..50]+'...' : ''
  end
  
  def type_desc
    Club.club_types.at(club_type).last
  end
  
  def format_desc
    Misc.format_red_cloth(description)
  end
  
  def free
    club_type == 0
  end  
  
  def member_emails
    active_club_members.map{|m| m.user.email}
  end

  def photo_markers_count
    photo_markers.count
  end
  
  def photo_markers
    MediaMarker.by_media_type_in_club(Photo, self)
  end
  
  #find all forums this user has access to for this club
  def forums_for_user(user)
   level = club_user_level(user)
   Forum.find(:all, :conditions => ["club_id = ? and access_level <= ?", self.id, level])
  end
  
  #check if club member
  def is_club_member(user)
    user && (self.active_club_members.find(:all, :conditions => ["user_id = ?",user.id]).length > 0) 
  end
  
  #check if club admin
  def is_club_admin(user)
    user && (self.user_id == user.id)
  end
  
  #check club user level for forum access
  def club_user_level(user)
    if is_club_admin(user)
      level = 2
    elsif is_club_member(user)
      level = 1
    else
      level = 0
    end
    return level
  end
  
  def collections_count
    Collection.count(:joins => "inner join club_members cm on cm.user_id = collections.user_id "+
                               "inner join clubs c on c.id = cm.club_id",
                     :conditions => ["c.id = ?",self.id])
  end
  
  def collections(limit = 10)
    Collection.find(:all, :select => 'collections.*', 
                     :joins => "inner join club_members cm on cm.user_id = collections.user_id "+
                               "inner join clubs c on c.id = cm.club_id",
                    :conditions => ["c.id = ?",self.id], :order => 'collections.created_at', :limit => limit)
  end
  
  def club_tags
    tag_list
  end
  
  def club_tags=(t)
    tag_with(t)
  end
  
  def name
    BadWord.filter_bad_words(read_attribute(:name))
  end
  
  def description
    BadWord.filter_bad_words(read_attribute(:description))
  end

  private

  def self.from_options_or_default(options)
    options[:page]  ||= 1
    options[:limit] ||= Configuration.photos_in_block
  end

  def destroy_dependancies
    self.club_members.delete
    self.news_items.delete
    self.forums.delete
  end
  
  
end
