class Admin::NewsItemsController < Admin::BaseController
  
  helper :markup
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @news_items = NewsItem.site_news.all.paginate :page => params[:page]
  end

  def show
    @news_item = NewsItem.find(params[:id])
  end

  def new
    @news_topics = NewsTopic.find(:all)
    #TODO: limit user list to only news authors otherwise could get ugly
    @users       = User.find(:all)
    @news_item = NewsItem.new
  end

  def create
    @news_item = NewsItem.new(params[:news_item].merge(:itemable_type => 'NewsTopic'))
    if not (@news_item.expire_item)
      @news_item.expire_item = 1
    end
    if @news_item.save
      flash[:notice] = 'News Item was successfully created.'
      redirect_to :action => 'list'
      #cache
      expire_center_block     
      #finally email to members if check box selected
      if params[:newsletter] && (params[:newsletter].to_i > 0) 
        for member in User.active_members
          UserMailer.deliver_newsletter(@news_item, member) if Notification.can_notify(member, 'System', 0, 'newsletter')
        end
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @news_topics = NewsTopic.find(:all)
    #TODO: limit user list to only news authors otherwise could get ugly
    @users       = User.find(:all)
    @news_item = NewsItem.find(params[:id])
  end
  
  def update
    @news_item = NewsItem.find(params[:id])
    if @news_item.update_attributes(params[:news_item])
      if not @news_item.expire_item
        @news_item.expire_date = nil
        @news_item.save
      end  
      #clear cache
      expire_center_block
      #
      flash[:notice] = 'News Item was successfully updated.'
      redirect_to :action => 'show', :id => @news_item
    else
      render :action => 'edit'
    end
  end

  def destroy
    NewsItem.find(params[:id]).destroy
    #clear cache
    expire_center_block
    #
    redirect_to :action => 'list'
  end
end
