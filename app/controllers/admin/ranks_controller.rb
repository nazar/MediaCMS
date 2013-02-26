class Admin::RanksController < Admin::BaseController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @rank_pages, @ranks = paginate :ranks, :per_page => 10
  end

  def show
    @rank = Rank.find(params[:id])
  end

  def new
    @rank = Rank.new
  end

  def create
    @rank = Rank.new(params[:rank])
    if @rank.save
      flash[:notice] = 'Rank was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @rank = Rank.find(params[:id])
  end

  def update
    @rank = Rank.find(params[:id])
    if @rank.update_attributes(params[:rank])
      flash[:notice] = 'Rank was successfully updated.'
      redirect_to :action => 'show', :id => @rank
    else
      render :action => 'edit'
    end
  end

  def destroy
    Rank.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
