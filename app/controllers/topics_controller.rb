class TopicsController < ApplicationController
  layout 'forums'
  
  helper :forums
  helper :markup
  
  include ForumsHelper #mixin to bring in check_forum_access

  verify :method => :post, :only => [ :create, :reply ]

  before_filter :login_required, :only => [:create, :edit, :update, :destroy]


  def new
    if current_user.blank?
      respond_to do |format|
        format.html{render :partial => '/forums/register', :layout => true}
        format.js{render :partial => '/forums/register'}
      end
    else
      @forum = Forum.find(params[:forum_id])

      check_forum_access(@forum) do
        @topic = Topic.new
        @topic.forum = @forum

        respond_to do |format|
          format.html{}
          format.js  {render :partial => 'posts/ajax_post_form', :locals => {:forum => @forum, :topic => @topic} }
        end
      end
    end
  end
  
  def show
    @forum = Forum.find(params[:forum_id])

    check_forum_access(@forum) do
      @topic = Topic.find(params[:topic_id])
      @last_post = @topic.posts.last
      @page_title = "Viewing Topic #{@topic.title}"

      @topic.hit! unless logged_in? and @topic.user == current_user
      @posts = @topic.posts.paginate :page => params[:page], :per_page => Configuration.forum_posts_per_page,
                                      :order => 'posts.created_at', :include => :user,
                                      :conditions => ['posts.topic_id = ?', params[:topic_id]]
      if @posts.length == 0
        step_notice('No posts were found in this topic')
      end
    end
  end  

  def next
    topic      = Topic.find(params[:topic_id])
    next_topic = Topic.next_topic(topic)
    if next_topic
      redirect_to topic_url(:forum_id => next_topic.forum_id, :topic_id => next_topic)
    else
      redirect_to topic_url(:forum_id => topic.forum_id, :topic_id => topic)
    end   
  end
  
  def previous
    topic      = Topic.find(params[:topic_id])
    next_topic = Topic.prev_topic(topic)
    if next_topic
      redirect_to topic_url(:forum_id => next_topic.forum_id, :topic_id => next_topic)
    else
      redirect_to topic_url(:forum_id => topic.forum_id, :topic_id => topic)
    end   
  end

  #When viewing topics list,  creates a new topic and the first post in that topic.
  #When viewing posts in a topic, creates a new topic and the first post in that.
  #In both instances, a redirect is peformed to the new topic and post (html and js)
  def create
    @forum = Forum.find(params[:forum_id]);
    unless params[:post].blank?
      check_forum_access(@forum) do
        @topic, @post = Topic.create_topic_and_post_from_params(params[:topic], @forum, current_user, request.remote_ip)
        if (@topic.errors.length > 0) || ( @post && (@post.errors.length > 0)  )
          render :action => :new
        else
          #expire cache
          expire_left_block
          redirect_to topic_url(:forum_id => @forum, :topic_id => @topic)
        end
      end
    else #cancel
      respond_to do |format|
        format.html do
          if params[:topic_id]
            redirect_to topic_path(@forum.id, params[:topic_id])
          else
            redirect_to forum_path(@forum.id)
          end
        end
        format.js {render :nothing => true}
      end
    end
  end
  
  #saves the reply
  def reply
    @topic = Topic.find(params[:topic_id])
    #possibly editing... check permissions..ie only owner or admin can edit
    if params[:edit] && params[:edit].to_i> 0
      post = Post.find(params[:edit])
      if admin? || (post.user_id == current_user.id)
        @post = post
        @post.update_attributes(params[:topic])
      end
    end
    #if not editing then create
    if @post.nil?  
      @post  = @topic.posts.build(params[:topic])
    end
    #save if the post has a body
    if @post.body?
      Topic.transaction do 
        @post.user = current_user
        @post.poster_ip = request.remote_ip
        if @topic.title != @post.title
          unless @post.read_attribute('title').blank? 
            @topic.title = @post.title
            @topic.save!
          else
            @post.title = @topic.title
          end
        end
        @post.save!
      end
      #expire cache
      expire_left_block
      #      
      redirect_to topic_url(:forum_id => @post.forum, :topic_id => @topic).to_s + "#post#{@post.id}"
    else
      redirect_to topic_url(:forum_id => @topic.forum, :topic_id=> @topic)
    end   
  end
  
end
