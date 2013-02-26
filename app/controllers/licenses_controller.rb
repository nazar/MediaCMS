class LicensesController < ApplicationController

  helper :markup
  
  before_filter :login_required, :except => [:list, :view]
    
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :add_license ],
         :redirect_to => { :action => :list }
         
  def list
    step_notice('Invalid request.')
  end
  
  def my
    if current_user.host_plan.own_license
      @page_title = 'My Licenses'
      #
      @licenses = License.user_licenses(current_user)
      @license  = License.new
      @license.default_price = Configuration.default_new_media_price
    else
      step_notice('<strong>Photo license management not available in this hosting plan.</strong>')
    end
  end
    
  def add
    @license = License.new(params[:license])
    #
    return unless request.post?
    @license.attributes = params[:license]
    @license.user_id = current_user.id
    if @license.save
      redirect_to license_my_path
    else
      render :action => :add
    end
  end
  
  def edit
    @license = License.find_by_id(params[:id])
    can_edit_license(@license) do
      @page_title = 'My Licenses'
      #
      return unless request.post?
      @license.attributes = params[:license]
      if @license.save
        redirect_to license_my_path
      else
        render :action => :edit
      end
    end
  end
  
  def delete
    @license = License.find(params[:id])
    @on_medias = @license.medias.count
    @page_title = 'Delete License'
    #
    if @on_medias.to_i == 0
      @license.destroy
      redirect_to license_my_path
    else
      render :action => :delete
    end
  end
  
  def view
    lic = License.find(params[:id])
    render :text => Misc.format_red_cloth(lic.description)
  end

  protected

  def can_edit_license(license)
    if current_user && current_user.host_plan.own_license && (license.user_id == current_user.id)
      yield
    else
      step_notice('Not authorised')
    end
  end

end
