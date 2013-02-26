class Admin::UsersController < Admin::BaseController

  active_scaffold :users do |config|
    config.label = "Registered Users"
    #host plan
    config.columns[:host_plan].clear_link 
    config.columns[:host_plan].form_ui = :select    
    #other actions
    config.action_links.add 'add_credit', :label => 'Add Credit', :type => :record, :inline => true, :position => :before
    config.action_links.add 'delete_user', :label => 'Delete', :type => :record, :prompt => true
    #remove default action links
    config.actions = [:list, :search, :update, :show, :nested, :subform]
    #columns
    config.list.columns   = [:id, :login, :name, :admin, :email, :credits, :activated, :created_at]
    config.show.columns   = [:id, :login, :name, :email, :billing_address_nice, :contact_name, :host_plan, :admin, :bio, :disk_space_used, :credits, :photos_count, :posts_count, :blogs_count, :total_sales, :paypal_email, :vip ]
    config.update.columns   = [:name, :email, :host_plan, :admin, :bio, :paypal_email, :active, :vip ]
  end 
  
  def add_credit
    @user = User.find(params[:id])
    if request.get?
      render :action => 'add_credit', :layout => false
    elsif request.post? #coming in from a post... save
      credits = params[:credits].to_f
      if credits > 0
        journal = Journal.manual_add_credit(@user, credits)
        CreditHistory.add_manual_credit(journal, credits, @user)
        User.add_credit(@user, credits)
      end
      page = params[:page] ? "/update_table?page_#{params[:page]}" : ''
      redirect_to "/admin/users#{page}"
    end  
  end

end
