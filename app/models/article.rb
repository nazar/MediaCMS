class Article < ActiveRecord::Base
  #approved: 0 - not approved yet, 1 - approved, -1 - rejected
  acts_as_commentable
  acts_as_rateable
  acts_as_taggable

  has_many :article_revisions do
    def last
      @last_revision ||= find(:first, :order => 'article_revisions.revision desc')
    end    
  end
  
  belongs_to :article_category, :counter_cache => true 
  belongs_to :user

  validates_presence_of :title, :article_category_id
  
  attr_accessor :body
  
  #class methods
  
  def self.articles_tagged_with(tag)
    Article.find( :all,  :select => 'articles.*',
        :joins => "inner join taggings t on articles.id = t.taggable_id and t.taggable_type = 'Article' and t.tag_id = #{tag.id}",
        :include => :article_category)
                  
  end
  
  def self.search(search_str)
    #TODO factor in revisions when search.
    Article.find(:all, :conditions => ['title like ? or description like ?',"%#{search_str}%","%#{search_str}%"])    
  end
  
  def self.get_unauthorised_articles
    Article.find(:all, :conditions => "approved = 0 or approved is null", :order => 'articles.created_at DESC',
                 :include => [:article_category, :user])
  end
    
  #instance methods
  
  def revise(params, user)
    params.each{ |att,value| self.send("#{att}=", value ) }
    self.transaction do
      self.save!
      ArticleRevision.revise_article(self, user)
    end
  end
  
  def status
    if active > 0
      if approved > 0 
        'Approved'
      else
        'Awaiting Approval'
      end
    else
      'Inactive'
    end
  end
  
  def latest_body
    rev = article_revisions.find(:first, :select => 'body, revision', :order => 'article_revisions.revision desc')
    if rev
      return rev.body, rev.revision
    else
      return '', 0
    end
  end
  
  def latest_rev
    body, rev = latest_body
    return rev
  end
  
  def approve_article
    self.body          = '1' #shameless hach
    self.approved      = 1
    self.approved_date = Time.now
    self.approved_by   = current_user.id
    self.approved_rev  = latest_rev
  end
  
  def unapprove_article
    self.body          = '1' #shameless hach
    self.approved      = nil
    self.approved_date = nil
    self.approved_by   = nil
    self.approved_rev  = nil
  end

  def approved_body
    #if approved rev is set return this rev... else return latest
    if strict_revs?
      if approved_rev > 0
        rev = ArticleRevision.find(:first, :select => 'body, revision', :conditions => ['id = ?',approved_rev])
        if rev
          return rev.body, rev.revision
        else
          return '', 0
        end
      else
        return latest_body
      end
    else
      return latest_body
    end
  end
  
  def previous_body_revision(revision)
    rev = ArticleRevision.find(:first, :conditions => ['article_id = ? and revision < ?',id, revision],
                               :order => 'revision DESC')
    return rev.body, rev.revision
  end
  
  def next_body_revision(revision)
    rev = ArticleRevision.find(:first, :conditions => ['article_id = ? and revision > ?',id, revision],
                               :order => 'revision ASC')
    return rev.body, rev.revision    
  end
  
  def approved_revision
    body, revision = approved_body
    return revision
  end
    
  def formatted_latest_body
    body, revision = latest_body
    return Misc.format_red_cloth(body), revision
    
  end
  
  def formatted_approved_body
    body, revision = approved_body
    return Misc.format_red_cloth(body), revision
  end
  
end
