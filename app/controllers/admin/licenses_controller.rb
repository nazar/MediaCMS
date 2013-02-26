class Admin::LicensesController < Admin::BaseController
  
  helper :markup
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @license_pages, @licenses = paginate :licenses, 
                          :conditions => 'user_id = 0', :order => 'name', :per_page => 10
  end

  def show
    @license = License.find(params[:id])
  end

  def new
    @license = License.new
  end

  def create
    @license = License.new(params[:license])
    if @license.save
      flash[:notice] = 'License was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @license = License.find(params[:id])
  end

  def update
    @license = License.find(params[:id])
    if @license.update_attributes(params[:license])
      flash[:notice] = 'License was successfully updated.'
      redirect_to :action => 'show', :id => @license
    else
      render :action => 'edit'
    end
  end

  def destroy
    License.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
