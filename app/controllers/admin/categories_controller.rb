class Admin::CategoriesController < Admin::BaseController

  cache_sweeper :category_cache, :only => [:create, :update, :destroy]

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @blockTitle = "List Categories"
  end

  def show
    @category = Category.find(params[:id])
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:notice] = 'Category was successfully created.'
      redirect_to :action => 'list'
      #expire cache
      expire_left_block
    else
      render :action => 'new'
    end
  end
  
  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    if @category.update_attributes(params[:category])
      flash[:notice] = 'Category was successfully updated.'
      redirect_to :action => 'show', :id => @category
      #expire cache
      expire_left_block
    else
      render :action => 'edit'
    end
  end

  def destroy
    Category.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

end
