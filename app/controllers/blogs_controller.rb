class BlogsController < ApplicationController
  helper :forums
  helper :markup
  
  before_filter :login_required, :only => [ :add, :edit, :delete, :add_comment, :my_blog ]
  before_filter :blog_enabled

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :add, :delete ],
         :redirect_to => { :action => :show }

  def index
    list
    render :action => 'list'
  end

  def list
    @page_title = "Viewing Latest Blogs"

    @blogs = Blog.paginate :per_page => Configuration.blogs_per_page, :page => params[:page], 
                           :order => 'blogs.created_at DESC', :include => :user
  end

  def show
    @blog = Blog.find(params[:id])
    @blog.blog_read += 1
    @blog.save
  end

  def my_blog
    #check if user host type can blog. If not then echo this
    check_can_blog
    @blog = Blog.new
    @blogs = Blog.paginate :page => params[:page], :per_page => Configuration.blogs_per_page,
                           :order => 'blogs.created_at Desc',
                           :conditions => ['user_id = ?',current_user.id]
  end
  
  def by
    @user = User.find_by_login(params[:id])
    @page_title = "Viewing blogs by #{@user.pretty_name}" 

    @blogs = Blog.paginate :page => params[:page], :per_page => Configuration.blogs_per_page,
                           :conditions => ['user_id = ?',@user.id],
                           :order => 'created_at DESC'
    @comment = Comment.new

  end
  
  def add
    #check if has submit priveledges
    check_can_blog
    #
    if params[:id]
      @blog = Blog.find(params[:id])
      if !(current_user && (current_user.id == @blog.user_id))
        redirect_to :action => 'show'
      end
      @blog.update_attributes(params[:blog])
    else
      @blog = Blog.new(params[:blog])
      @blog.user = current_user
      #current_user.blogs_count += 1
      #current_user.save
    end
    if @blog.save
      flash[:notice] = 'Blog was successfully created.'
      redirect_to :action => 'my_blog'
      #expire cache
      expire_left_block
    else
      render :action => 'my_blog'
    end
  end

  def edit
    check_can_blog
    @blog = Blog.find(params[:id])
    #can only edit own blog
    if !(current_user && (current_user.id == @blog.user_id))
      redirect_to :action => 'my_blog'
    end
  end
  
  def delete
    blog = Blog.find(params[:id])
    if (blog && current_user && (current_user.id == blog.user_id)) || 
       (current_user && current_user.admin)
      blog.destroy
    end
    redirect_to :action => 'my_blog'
  end
    
  protected
  
  def check_can_blog
    if current_user.host_plan.can_blog
      return true
    else
      up_link = "<a href='#{url_for :controller => 'account', :action => :account}'>upgrade your account</a>"
      step_notice("Blogging is not available for this host plan. Please #{up_link} to use our blogging facilities")
    end
  end
  
  def blog_enabled
    return if Configuration.module_blogs
    step_notice('<h1>Module Disabled</h1>')
  end
  
end
