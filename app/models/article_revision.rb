class ArticleRevision < ActiveRecord::Base
  belongs_to :article, :counter_cache => :revs_count

  #class methods
  
  def self.revise_article(article, user)
    #find latest revision then up-rev
    last = self.find(:first, :conditions => ['article_id = ?',article.id], :order => 'revision desc')
    #revise only if body has changed
    if (last.nil?) || (article.body != last.body)
      last = self.new( :article_id => article.id, :revision => 0) if !last
      #uprev
      new_last = last.clone
      new_last.user_id = user.id
      new_last.created_at = Time.now
      new_last.revision += 1
      new_last.body = article.body
      new_last.save!
    end
  end
  
  #instance methods
    
  
end
