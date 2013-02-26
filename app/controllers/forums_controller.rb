class ForumsController < ApplicationController

include ForumsHelper

before_filter :forum_module_enabled

def index
    @public_forums = Forum.public_forums
    @clubs = Club.clubs_with_forums
    @page_title = 'Viewing Forums Index'
  end
  
  def show
    @forum = Forum.find(params[:id])
    @page_title = "Viewing Forum #{h @forum.name}"

    # keep track of when we last viewed this forum for activity indicators
    (session[:forums] ||= {})[@forum.id] = Time.now.utc if logged_in?
    #check if this is a public forum or club specific... if club then must check permissions
    check_forum_access(@forum) do
      @topics = Topic.by_forum(@forum).paginate(:page => params[:page], :per_page => Configuration.forum_posts_per_page)
    end
  end
  
  def edit_post
    comment = Post.find(params[:id])
    render :update do |page|
      edit_post_ajax(page, comment)
    end
  end
  
  def preview_post 
    comment = Post.find(params[:id])
    edit_text = params["#{comment.id}_editor".to_sym]
    render :update do |page|
      preview_post_ajax(page, comment, edit_text)
    end
  end
  
  def save_post
    comment = Post.find(params[:id])
    edit_text = params["#{comment.id}_editor".to_sym]
    render :update do |page|
      save_post_ajax(page, comment, edit_text)
    end
  end
  
  protected
  
  def forum_module_enabled
    return if Configuration.module_forums
    step_notice('<h1>Forums module disabled</h1>')
  end
  
  
end
