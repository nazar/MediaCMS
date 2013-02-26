class Admin::ConfigurationsController < Admin::BaseController

  helper :configuration

  verify :method => :post, :only => [ :update ],
         :redirect_to => { :action => :index }

  def index
    render :action => :index
    @page_title = 'Site Configuration'
  end
  
  def update
    Configuration.transaction do
      Configuration.assign_values(params)
    end
    #clear caches
    expire_center_block
    expire_more_photos
    #
    render :action => 'index'
  end
  
end
