class PostsController < ApplicationController
  helper :markup
  layout 'forums'

  before_filter :login_required, :except => [:reply], 
                :redirect_to => { :controller => :forums, :action => :index } 

  #shows the reply form
  def reply
    if !current_user
      render :partial => '/forums/register', :layout => true 
      return
    end
    # 
    @post  = Post.find(params[:post_id])
    @forum = @post.forum
    @topic = @post.topic
    #
    render_reply_form
  end

  def quote
    @post  = Post.find(params[:post_id])
    @forum = @post.forum
    @topic = @post.topic
    @topic.body = @post.quote_body 
    #
    render_reply_form
  end
  
  def edit
    @post  = Post.find(params[:post_id])
    @forum = @post.forum
    @topic = @post.topic
    @topic.body = @post.body 
  end
  
  def delete
    @post  = Post.find(params[:post_id])
    topic  = @post.topic
    forum  = topic.forum
    #only an admin can delete a post
    can_admin? do
      Post.transaction do
        if topic.posts_count = 1
          @post.destroy
          topic.destroy ##only single post in topic... delete topic as well
          redirect_to forum_path(:id=>forum)
        else
          @post.destroy
          redirect_to topic_path(:forum_id=>forum, :topic_id=>topic)
        end
      end
    end
  end

  protected

  def render_reply_form
    respond_to do |format|
      format.html {}
      format.js   {render :partial => 'posts/ajax_reply_form', :locals => {:forum => @forum, :topic => @topic, :post => @post} }
    end
  end
 
end
