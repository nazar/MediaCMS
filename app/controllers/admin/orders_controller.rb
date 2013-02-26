class Admin::OrdersController < Admin::BaseController
  
  active_scaffold :order do |config|
    config.label = "Orders"
    #remove default action links
    config.actions = [:list, :search, :nested, :subform]
    #columns
    config.list.columns   = [:id, :created_at, :status_desc, :customer_ip]
    config.columns[:customer_ip].label = 'IP'
  end 
  
  def pending
    active_scaffold_config.label = "Pending Orders"
    #list
    active_scaffold_config.list.columns.exclude :transaction
    active_scaffold_config.list.columns.add :total, :purchase_order, :user
    #links
    active_scaffold_config.action_links.add 'credit_account', :label => 'Credit Account', :type => :record, :position => :replace, :crud_type => :destroy
  end
  
  def credit_account
    order = Order.find_by_id(params[:id])
    Order.transaction do
      #populate ledger if credit has been bought
      journal = Journal.manual_add_credit(order, order.total)
      #populate credit history table if credit has been bought
      CreditHistory.add_manual_credit(journal, order.total, order.user)
      #credit user account
      User.add_credit(order.user, order.total)
      UserMailer.deliver_order_complete(order)
      #close order
      order.gate_transaction = "processed by #{current_user.id} at #{Time.now.to_s}"
      order.status = 4
      order.save
    end
    if request.xhr?
      render :text => 'account credited'
    else
    #reload
      page = params[:page] ? "?page=#{params[:page]}" : ''
      redirect_to "/admin/orders/pending#{page}"
    end
  end
  
end
