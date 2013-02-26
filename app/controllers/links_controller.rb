class LinksController < ApplicationController

  helper :markup, :forums, :comments

  #verify :method => :post, :only => [ :add_comment ]
  before_filter :login_required, :except => [:index, :view, :out, :vote, :today, :week, :month]
  before_filter :links_module_enabled

  def index
    @page_title = 'Viewing Popular Links'
    id = current_user ? current_user.id : 0
    #TODO Config option for number of links per page
    @links = Link.paginate :page => params[:page], :per_page => 20, :select => 'links.*, favourites.id saved',
                           :joins => "left join favourites on links.id = favourites.favouriteable_id and favourites.favouriteable_type = 'Link' and favourites.user_id = #{id}",
                           :order => 'Date(links.created_at) DESC, votes_up DESC' 
  end
  
  def today
    id = current_user ? current_user.id : 0
    @page_title = "Viewing Today's Popular Links"
    time_start = Date.today
    time_end   = Date.today + 1.day
    @links_pages, @links = get_period_links(id, time_start, time_end)
    render :action => :index                              
  end
  
  def week
    id = current_user ? current_user.id : 0
    @page_title = "Viewing This Week's Popular Links"
    time_start = Date.today.monday
    time_end   = time_start.next_week
    @links_pages, @links = get_period_links(id, time_start, time_end)
    render :action => :index                              
  end
  
  def month
    id = current_user ? current_user.id : 0
    @page_title = "Viewing This Month's Popular Links"
    time_start = Date.today.beginning_of_month
    time_end   = Date.today.end_of_month
    @links_pages, @links = get_period_links(id, time_start, time_end)
    render :action => :index                              
  end
  
  def add_link
    @page_title = 'Submit a Link'
    @link = Link.new(params[:link])
    return if not request.post?
    Link.transaction do
      @link.user_id = current_user.id
      @link.save
      if @link.errors.length > 0
        render :action => :add_link
        return false
      end
      #add screenshot task
      ServerTask.take_link_screenshot(@link)
    end  
    redirect_to :action => :my_links
  end
  
  def my_links
    @page_title = 'Viewing My Links'
    @links = Link.get_user_links(current_user)
  end
  
  def my_favourites
    @page_title = 'Viewing My Favourite Links'
    @bookmarks = Link.get_my_favourites(current_user)
  end
  
  def view
    @link = Link.find(params[:id])
    @saved = Favourite.find_favourites_for_favouriteable('Link', @link.id)
    @page_title = "Viewing #{@link.name}"
    @link.increment_views;
    @comment = Comment.new
  end
  
  def out
    link = Link.find(params[:id])
    link.increment_clicks;    
    redirect_to link.link
  end
  
  def vote
    search_bot_allowed_here do  
      #check if already voted
      if logged_in?
        voted = Rating.count(:conditions => ['rateable_id = ? and rateable_type = ? and user_id = ?',
                                      params[:id],'Link',current_user.id]) > 0
      else
        voted = Rating.count(:conditions => ['rateable_id = ? and rateable_type = ? and ip = ?',
                                      params[:id],'Link',request.remote_ip]) > 0
      end
      if voted
        render :update do |p|
          p.alert("You've already voted")
        end
      else
        #increment and update
        @link = Link.find(params[:id])
        Rating.transaction do
          oRating = Rating.new( :rating => 1,
                                :ip => request.remote_ip,
                                :user_id => current_user ? current_user.id : 0)
          @link.increment_vote
          @link.save
          @link.add_rating oRating
        end
        #render update
        render :update do |p|
          p.replace_html "link_#{@link.id}", :partial => '/links/render_link', :locals => {:link => @link, :saved => @link.lookup_saved(current_user)}
        end
      end
    end  
  end
  
  def favourite
    #only for our members
    unless logged_in?
      render :update do |p|
        p.alert 'Link saving is available to registered members only. Register for a free account now.'
      end
      return
    end
    @link = Link.find(params[:id])
    #check not added already
    unless Favourite.find_favourites_for_favouriteable('Link', @link.id).by_user(current_user).count == 0
      render :update do |p|
        p.alert('Link already in your favourites')
      end
      return
    end
    #create and add
    Link.transaction do
      fav = Favourite.new(:user_id => current_user.id)
      @link.increment_favourited
      @link.add_favourite fav
    end
    #render update
    render :update do |p| 
      p.replace_html "link_#{@link.id}", :partial => '/links/render_link', :locals => {:link => @link, :saved => true}
    end
  end
                                                                
  protected
  
  def get_period_links(id, time_start, time_end)
    paginate :links, :per_page => 20, :select => 'links.*, favourites.id saved',
                                    :joins => "left join favourites on links.id = favourites.favouriteable_id and favourites.favouriteable_type = 'Link' and favourites.user_id = #{id}",
                                    :conditions => ["links.created_at between ? and ?",time_start, time_end],
                                    :order => 'votes_up DESC'     
  end
  
  def links_module_enabled
    return if Configuration.module_links
    step_notice('<h1>Module disabled</h1>')
  end
  
end
