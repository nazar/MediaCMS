class CommentsController < ApplicationController
  
  helper :forums, :markup
  
  verify :method => :post, :only => [ :add_comment, :update ]
  before_filter :login_required, :except => [:add_comment]

  def add_comment
    #check if anon can comment
    return if current_user.nil? && (not Configuration.anonymous_comments)
    #safe to continue
    commentable_type = params[:commentable][:commentable]
    commentable_id   = params[:commentable][:commentable_id]
    # Get the object that you want to comment
    commentable = Comment.find_commentable(commentable_type, commentable_id)
    # Create a comment with the user submitted content
    comment = Comment.new(params[:comment])
    Comment.transaction do
      # Assign this comment to the logged in user
      comment.user_id = current_user ? current_user.id : 0
      comment.ip      = request.remote_ip
#      comment.dns     = get_ip_host(request.remote_ip) #TODO defer this for background processing
      comment.commentable_type = commentable_type
      comment.commentable_id   = commentable_id
      comment.user_id = current_user ? current_user.id : 0
      #spam check only for anon users for the time being
      if current_user
        comment.spam = 0
      else
        if Configuration.enable_recaptcha
          comment.spam = verify_recaptcha(:private_key => Configuration.recaptcha_private_key)? 0 : 1
        else
          comment.spam = 0
        end
      end
      #increment user post count - this is not the same as comments count, which is incremented by Comment on save
      if current_user
        self.current_user.posts_count += 1
        self.current_user.save
      end
      #if spam then place in comment failed
      if comment.spam
        logger.info("Spam detected from IP #{request.remote_ip}")
        #
        flash[:failed] = comment
        flash[:failed_msg] = 'Captcha Check Failed'
        #
        respond_to do |format|
          format.html {redirect_to comment_view_link(comment, :anchor => true)}
          format.js   do
            render :update do |page|
              page.alert('captcha failed');
            end
          end
        end
      else
        #save comment and observer kicks in here
        comment.save!
        flash[:failed] = nil
        flash[:failed_msg] = ''
        #
        respond_to do |format|
          format.html {redirect_to comment_view_link(comment, :anchor => true)}
          format.js   {render :partial => 'comments/comment_row', :locals => {:comment => comment, :commentable => commentable}}
        end
        #finally... send notification
        Notification.new_comment(commentable, comment, comment_view_link(comment, :anchor => true))
      end
    end
  end

  def edit
    @comment = Comment.find_by_id(params[:id])
    if @comment.can_edit(current_user)
      respond_to do |format|
        format.html {redirect_to comment_view_link(@comment, :anchor => true)} #edit only using js
        format.js   {render :partial => 'comments/update_comment', :locals => {:model => @comment.commentable}}
      end
    else
      step_notice('invalid request')
    end
  end

  def update
    @comment = Comment.find_by_id params[:id]
    if params[:save_comment] && @comment.can_edit(current_user)
      @comment.title = params[:comment][:title]
      @comment.body  = params[:comment][:body]
      @comment.ip    = request.remote_ip;
      @comment.save!
    end
    respond_to do |format|
      format.js   {render :partial => 'comments/comment_row', :locals => {:comment => @comment, :commentable => @comment.commentable}}
      format.html {redirect_to comment_view_link(@comment, :anchor => true)}
    end
  end

  def delete
    return unless admin?
    comment = Comment.find_by_id params[:id]
    comment.destroy;
    respond_to do |format|
      format.js   {render :nothing => true, :status => 200}
      format.html {redirect_to(comment_view_link(comment)) }
    end
  end

  def spam
    return unless admin?
    comment = Comment.find_by_id params[:id]
    Comment.transaction do
      #submit spam to akismet
      submit_spam(:comment_content   => comment.body,
                 :comment_type       => 'comment',
                 :comment_author     => comment.anon_name,
                 :comment_author_url => comment.anon_url,
                 :permalink          => comment_view_link(comment))
      #came back fine...now destroy
      comment.destroy;
   end
    respond_to do |format|
      format.js   {render :nothing => true, :status => 200}
      format.html {redirect_to(comment_view_link(comment)) }
    end
  end
    
  def delete_comment
    comment     = Comment.find(params[:id])
    commentable = Comment.find_commentable(params[:commentable], params[:commentable_id])
    #decrement count for host object
    Comment.transaction do
      commentable.comments_count -= 1 if commentable.comments_count > 0
      commentable.save
      #remove from page
      render :update do |page|
        page.remove("comment_row_#{comment.id}")
      end
      #destroy
      comment.destroy
    end
  end
    
#  def edit_post #TODO remove
#    comment = Comment.find(params[:id])
#    render :update do |page|
#      edit_post_ajax(page, comment)
#    end
#  end
  
#  def preview_post
#    comment = Comment.find(params[:id])
#    edit_text = params["#{comment.id}_editor".to_sym]
#    render :update do |page|
#      preview_post_ajax(page, comment, edit_text)
#    end
#  end
  
#  def save_post
#    comment = Comment.find(params[:id])
#    edit_text = params["#{comment.id}_editor".to_sym]
#    render :update do |page|
#      save_post_ajax(page, comment, edit_text)
#    end
#  end

  protected

  def comment_view_link(comment, options={})
    commentable    = comment.get_commentable
    commented_link = eval("#{commentable.class.to_s.downcase}_view_link_url(:id => commentable.id)")
    unless options[:anchor].blank?
      if comment.id.to_i > 0
        commented_link = "#{commented_link}#comment-#{comment.id}"
      else
        commented_link = "#{commented_link}#comment"
      end
    end
    commented_link
  end
    

end
