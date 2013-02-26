class Comment < CommentBase

  named_scope :by_media_type, lambda{|klass| #replaces :photos named_scope
    { :conditions => {:commentable_type => 'Media'},
      :joins => "inner join medias on medias.id = comments.commentable_id and medias.type = '#{klass.to_s}'"
    }
  }

  named_scope :by_user, lambda { |user|
    { :conditions => ['comments.user_id = ?', user.id] }
  }

  named_scope :not_spam, {:conditions => {:spam => 0}}

  #scopes

  def self.latest_comments(options={}, &block)
    options[:limit] ||= 10
    self.scope_or_yield(
            Comment.scoped({:conditions => 'spam = 0', :order => 'created_at DESC'}.merge(options)),
            &block)
  end

  #class methods

  #instance methods
  
  def body
    BadWord.filter_bad_words(read_attribute(:body))
  end

  def title
    BadWord.filter_bad_words(read_attribute(:title))
  end
  
  def body_excerpt(size = 20)
    body && body.length > size ? body[1..size] << '...' : body
  end

  def photo
    raise "Photo requested on comment id #{id} when type was actaully #{commentable.type}" unless commentable.type.to_s == 'Photo'
    commentable
  end

  #comment can only be edited by an admin or withing x mins if comment owner
  def can_edit(user)
    unless user.nil?
      user.admin? || ((user.id == user_id) && (updated_at < 5.minutes.ago)) #TODO add to Configuration class
    else
      false
    end
  end
  
end  
  
  
#end