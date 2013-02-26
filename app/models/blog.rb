class Blog < ActiveRecord::Base

  acts_as_commentable
  
  belongs_to :user, :counter_cache => true

  named_scope :order_desc, :order => 'created_at DESC'

  named_scope :by_title_or_description, lambda{|search|
    {:conditions => ['title like ? or body like ?', "%#{search}%", "%#{search}%"]}
  }
  
  #class methods
  def Blog.get_user_blogs_order_date(user, limit = 0)
    if limit > 0
      Blog.find(:all, :order => 'created_at DESC', :conditions => ['user_id = ?',user.id], 
                      :limit => limit)
    else
      Blog.find(:all, :order => 'created_at DESC', :conditions => ['user_id = ?',user.id])
    end
  end
  
  def Blog.get_blogs_order_date(limit = 0)
    if limit > 0
      Blog.find(:all, :order => 'created_at DESC', :limit => limit)
    else
      Blog.find(:all, :order => 'created_at DESC')
    end
  end
  
  def Blog.last_blog_entry
    Blog.find(:all, :order => 'created_at DESC', :limit => 1)
  end
  
  #instanace methods
  
  def formatted_body
    Misc.format_red_cloth(body)
  end
  
  def spotlight
    #check if spotlight is defined in body... if not then summary
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
  
  def title
    BadWord.filter_bad_words(read_attribute(:title))
  end
  
  def body
    BadWord.filter_bad_words(read_attribute(:body)) 
  end
  
end