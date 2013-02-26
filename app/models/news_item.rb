class NewsItem < ActiveRecord::Base

  acts_as_commentable
  
  belongs_to :itemable, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :title
  validates_presence_of :body

  named_scope :site_news, :conditions => {:itemable_type => 'NewsTopic' }
  named_scope :club_news, :conditions => {:itemable_type => 'Club' }
  named_scope :latest_first, :order => 'created_at DESC'
  named_scope :active, :conditions => ['(expire_item = 0) or ( (expire_item = 1 ) and (expire_date < ?) ) and (active = 1)', Time.new]

  #scoped class methods
  
  def self.latest_active_items(limit = 10)
    NewsItem.active.latest_first.scoped( :limit => limit )
  end

  #class methods

  def self.per_page
    10
  end
  
  def self.latest_item
    NewsItem.latest_active_items(1)
  end

  def self.increment_views(news)
    news.read += 1
    news.save
  end

  
  #instance methods
  
  def spotlight
    #check if spotlight is defined in body... if not then return whole body
    spotlight = body.match('<spotlight>(.*)</spotlight>') 
    if spotlight
      return Misc.format_red_cloth(spotlight.to_s)
    elsif body
      return Misc.format_red_cloth(truncated_text)
    end
  end
  
  def truncated_text(max = 200)
    bd = body
    if bd.length > max
      bd = bd[0,max] + '...'
    end
    return bd
  end
  
  def formatted_body
    Misc.format_red_cloth(body)
  end
  
  def formatted_extra
    Misc.format_red_cloth(extra) if extra
  end
  
  def status_desc
    if active
      'Published'
    else
      'Hidden'
    end
  end
    
end
