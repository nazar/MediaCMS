class HostPlansController < ApplicationController
  include ActiveMerchant::Billing::Integrations
    
  before_filter :login_required

  verify :method => :post, :only => [ :update_plan ],
         :redirect_to => { :action => :account }

  def account
    @plan = current_user.host_plan
  end
  
  def upgrade
    @plans = HostPlan.find(:all, :order => 'monthly_fee')
    @user  = current_user
  end  
  
  def update_plan
    ActiveMerchant::Billing::Base.integration_mode = :test if Configuration.test_payment_processing
    #
    @user = User.find(current_user.id)
    @plan = HostPlan.find(params[:user][:host_plan_id])
    @account = Configuration.paypal_email
    #update only if the plans differ
    if @user.host_plan_id != @plan.id
      render :action => :update_plan, :layout => 'auto_post'
    else
      step_notice('<h3>Host plan not updated.</h3>')
    end
  end
  
end