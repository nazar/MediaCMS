class Admin::TopPageController < Admin::BaseController

  helper :markup
  
  verify :method => :post, :only => [ :update ],
         :redirect_to => { :action => :index }
  
  def index
    @page_title = 'Header and Top Page Configuration'
  end  
  
  def update 
    Configuration.set_values(params)
    render :action => 'index'
  end
  
  
end
