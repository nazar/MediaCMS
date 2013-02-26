class Admin::CommentsController < Admin::BaseController
  
  active_scaffold :comment do |config|
    config.label = "Comments Managament"
    #host plan
    config.action_links.add 'mark_spam', :label => 'Spam', :type => :record
    #remove default action links
    config.actions = [:list, :search, :update, :show, :nested, :subform]
    #columns
    config.list.columns   = [:title, :body_excerpt, :created_at ]
    config.update.columns   = [:anon_name, :anon_url, :title, :body ]
  end   
  
  def mark_spam
    comment = Comment.find_by_id(params[:id])
    #don't want this crap in our database.... delete
    comment.destroy if comment
  end
  
  def spam
    @page_title = 'Logs'  
    @spam = Comment.spam_comments
  end
  
  def process_spam
    if params['spam']
      Comment.transaction do
        params['spam'].each do |key,value| 
          if params['option'] == 'delete'
            Comment.delete(key)
          elsif params['option'] == 'ham'
            is_ham(key)
          end
        end
      end
    end
    redirect_to :action => :spam
  end  
  
  private
  
  def is_ham(comment_id)
    comment = Comment.find(comment_id)
    comment.spam = 0
    comment.save
    #notify since this is ham
    #Notification.new_comment(Comment.find_commentable(comment.commentable_type, comment.commentable_id), comment, commented_link) #TODO fix
  end
  
end