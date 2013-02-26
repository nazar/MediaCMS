class Post < ActiveRecord::Base
  
  belongs_to :forum, :counter_cache => true
  belongs_to :user,  :counter_cache => true
  belongs_to :topic, :counter_cache => true

  #format_attribute :body
  before_create { |r| r.forum_id = r.topic.forum_id }
  after_create  { |r| Topic.update_all( ['replied_at = ?, replied_by = ?, last_post_id = ?', r.created_at, r.user_id, r.id],
                                        ['id = ?', r.topic_id])
                      Forum.update_all( ['last_posted = ?', Time.new], ['id = ?', r.forum_id])
                }
  after_destroy { |r| t = Topic.find(r.topic_id) ;
                          Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', t.posts.last.created_at, t.posts.last.user_id, t.posts.last.id], ['id = ?', t.id]) if t.posts.last }

  validates_presence_of :user_id, :body
  attr_accessible :body

  named_scope :with_forum, :include => :forum
  named_scope :order_desc, :order => 'created_at DESC'

  named_scope :by_title_or_body, lambda{|search|
    {:conditions => ['title like ? or body like ?', "%#{search}%", "%#{search}%"]}
  }
  
  def editable_by?(user)
    user && (user.id == user_id || user.admin? || user.moderator_of?(topic.forum_id))
  end
  
  def quote_body
    quote = ''
    body.split("\n").each do |match|
      (quote << "bq. #{match}" << "\n\n") unless match.blank?
    end
    #
    "_#{user.pretty_name} said:_\n\n#{quote}"
  end
  
  def formatted_body
    Misc.format_red_cloth(body)
  end
  
  def body
    BadWord.filter_bad_words(read_attribute(:body))
  end
  
  def title
    if read_attribute(:title) && read_attribute(:title).length > 0
      BadWord.filter_bad_words(read_attribute(:title))
    else
      body && (body.length > 30) ? body[1..30] : body
    end
  end
  
end
