class Topic < ActiveRecord::Base
  
  belongs_to :forum, :counter_cache => true
  belongs_to :user
  has_many :monitorships
  has_many :monitors, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :source => :user, :order => 'users.login'

  has_many :posts, :order => 'posts.created_at', :dependent => :destroy do
    def last
      @last_post ||= find(:first, :order => 'posts.created_at desc')
    end
  end

  named_scope :by_forum, lambda{|forum|
    { :conditions => ['forum_id = ?', forum.id], :include => :replied_by_user,  :order => 'sticky desc, topics.created_at DESC' } 
  }

  belongs_to :replied_by_user, :foreign_key => "replied_by", :class_name => "User"
  
  validates_presence_of :forum, :user, :title
  
  before_create { |r| r.replied_at = Time.now.utc }
  after_save    { |r| Post.update_all ['forum_id = ?', r.forum_id], ['topic_id = ?', r.id] }

  attr_accessible :title
  # to help with the create form
  attr_accessor :body
  
  #class methods
  
  def self.latest_topics(limit=10)
    topics = Topic.find( :all, :order => 'created_at DESC', :limit => limit)
    if block_given?
      topics.map {|t| yield t}
    else
      topics
    end
  end
  
  def self.next_topic(topic)
    #get first topic posted after this topic on the same forum
    tpc = Topic.find( :all, 
                      :conditions => ['forum_id = ? and created_at < ?', topic.forum_id, topic.created_at],
                      :limit => 1,
                      :order => 'created_at DESC')
    if tpc
      return tpc[0]
    else
      return false
    end
  end
  
  def self.prev_topic(topic)
    tpc = Topic.find( :all, 
                      :conditions => ['forum_id = ? and created_at > ?', topic.forum_id, topic.created_at],
                      :limit => 1,
                      :order => 'created_at DESC')
    if tpc
      return tpc[0]
    else
      return false
    end
  end

  def self.create_topic_and_post_from_params(params, forum, user, ip)
    Topic.transaction do
      topic       = forum.topics.build(params)
      topic.user  = current_user
      if current_user.admin?
        topic.locked   = params[:locked]
        topic.sticky   = params[:sticky]
      end
      topic.save
      post = nil
      if topic.errors.blank?
        #next create the first post in the topic
        post = topic.posts.build(params)
        post.user = user
        post.poster_ip = ip
        post.save
      else
        topic.body = params[:body]
      end
      #
      return topic, post
    end
  end
  
  #instance methods
  
  
  def voices
    posts.map { |p| p.user_id }.uniq.size
  end
  
  def hit!
    self.class.increment_counter :hits, id
  end

  def sticky?() sticky == 1 end

  def views() hits end

  def paged?() posts_count > 25 end
  
  def last_page
    (posts_count.to_f / 25.0).ceil.to_i
  end
  
  def editable_by?(user)
    user && (user.id == user_id || user.admin? || user.moderator_of?(forum_id))
  end
  
#  def title
#    raise read_attribute(:title)
#    BadWord.filter_bad_words(read_attribute(:title))
#  end
  
end
