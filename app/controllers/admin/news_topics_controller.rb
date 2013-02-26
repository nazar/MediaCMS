class Admin::NewsTopicsController < Admin::BaseController
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @news_topic_pages, @news_topics = paginate :news_topics, :per_page => 10
  end

  def show
    @news_topic = NewsTopic.find(params[:id])
  end

  def new
    @news_topic = NewsTopic.new
  end

  def create
    @news_topic = NewsTopic.new(params[:news_topic])
    if @news_topic.save
      flash[:notice] = 'News Topic was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @news_topic = NewsTopic.find(params[:id])
  end

  def update
    @news_topic = NewsTopic.find(params[:id])
    if @news_topic.update_attributes(params[:news_topic])
      flash[:notice] = 'News Topic was successfully updated.'
      redirect_to :action => 'show', :id => @news_topic
    else
      render :action => 'edit'
    end
  end

  def destroy
    NewsTopic.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
