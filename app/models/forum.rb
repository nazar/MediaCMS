class Forum < ActiveRecord::Base

  acts_as_list
  
  validates_presence_of :name

  has_many :topics, :order => 'sticky desc, replied_at desc', :dependent => :destroy do
    def first
      @first_topic ||= find(:first)
    end
  end

  has_many :posts, :order => 'posts.created_at desc' do
    def last
      @last_post ||= find(:first, :include => :user)
    end
  end
  
  belongs_to :club

  #class methods

  def self.busiest_forums(options={}, &block)
    options[:limit] ||= 10
    self.scope_or_yield(
            Forum.scoped({:conditions => 'posts_count > 0', :order => 'posts_count DESC'}.merge(options)),
            &block)
  end

  
  def self.access_level_types
    { 0 => 'Visible to all',
      1 => 'Visible to club members',
      2 => 'Visible to admins only' }
  end
  
  def self.public_forums
    Forum.find(:all, :conditions => "club_id = 0", :order => 'position')
  end
  
  #instance methods
  
  def name
    BadWord.filter_bad_words(read_attribute(:name))
  end
  
  def description
    BadWord.filter_bad_words(read_attribute(:description))
  end

  def access_level_to_s
    Forum.access_level_types[access_level]
  end
  

end
