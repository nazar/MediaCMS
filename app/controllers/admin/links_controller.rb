class Admin::LinksController < Admin::BaseController
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @links_pages, @links = paginate :links, :per_page => 10
  end

  def show
    @links = Links.find(params[:id])
  end

  def new
    @links = Links.new
  end

  def create
    @links = Links.new(params[:links])
    if @links.save
      flash[:notice] = 'Links was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @links = Links.find(params[:id])
  end

  def update
    @links = Links.find(params[:id])
    if @links.update_attributes(params[:links])
      flash[:notice] = 'Links was successfully updated.'
      redirect_to :action => 'show', :id => @links
    else
      render :action => 'edit'
    end
  end

  def destroy
    Links.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
