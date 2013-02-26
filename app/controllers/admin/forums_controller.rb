class Admin::ForumsController < Admin::BaseController

  helper :markup

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @forum_pages, @forums = paginate :forums, :per_page => 20, :order => 'position'
  end

  def show
    @forum = Forum.find(params[:id])
  end

  def new
    @forum = Forum.new
  end

  def create
    @forum = Forum.new(params[:forum])
    if @forum.save
      @forum.insert_at(params[:forum][:position])
      @forum.save
      #
      flash[:notice] = 'Forum was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @forum = Forum.find(params[:id])
  end

  def update
    @forum = Forum.find(params[:id])
    if @forum.update_attributes(params[:forum])
      flash[:notice] = 'Forum was successfully updated.'
      redirect_to :action => 'show', :id => @forum
    else
      render :action => 'edit'
    end
  end

  def destroy
    Forum.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
