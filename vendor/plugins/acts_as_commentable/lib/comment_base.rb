class CommentBase < ActiveRecord::Base
  
  set_table_name 'comments'
  
  after_create :increment_count
  after_destroy :decrement_count
  
  belongs_to :commentable, :polymorphic => true
  
  # NOTE: install the acts_as_votable plugin if you 
  # want user to vote on the quality of comments.
  #acts_as_voteable
  
  # NOTE: Comments belong to a user
  belongs_to :user
  
  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  def self.find_comments_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
  
  # Helper class method to look up all comments for 
  # commentable class name and commentable id.
  def self.find_comments_for_commentable(commentable_str, commentable_id)
    find(:all,
      :conditions => ["commentable_type = ? and commentable_id = ?", commentable_str, commentable_id],
      :order => "created_at DESC"
    )
  end
  
  # Helper class method to look up a commentable object
  # given the commentable class name and id 
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id) if commentable_str && commentable_id
  end
    
  def self.spam_comments
    Comment.find(:all, :conditions => 'spam=1', :order => 'created_at DESC')
  end

  def self.delete_all_spam
    Comment.delete_all('spam=1') 
  end
  
  def user_name
    user_id > 0 ? user.login : 'anonymous'
  end
  
  #instance methods
  
  def formatted_body
    if body
      Misc.format_red_cloth(body)
    end
  end
  
  def safe_title
    if title && title.length > 0
      result =  title
    elsif body 
      result = body[0,50]+'...'
    else
      result = '' 
    end
    #htmltize 
    return Misc.format_red_cloth(result)
  end

  #cater for STI inheritable models
  def commentable_type=(sType)
     super(sType.constantize.base_class.name)
  end

  def get_commentable
    commentable_type.constantize.find_by_id(commentable_id)
  end
  
  protected
  
  def increment_count
    comment_object = Comment.find_commentable(commentable_type, commentable_id)
    if comment_object
      comment_object.comments_count +=  1
      comment_object.save
    end
  end
  
  def decrement_count
    comment_object = Comment.find_commentable(commentable_type, commentable_id)
    if comment_object
      comment_object.comments_count -=  1
      comment_object.save    
    end
  end
  
end