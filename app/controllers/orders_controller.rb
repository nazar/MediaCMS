class OrdersController < ApplicationController
  
  include ActiveMerchant::Billing::Integrations
    
  before_filter :login_required, :except => [:ipn_notify, :worldpay_notify, :ipn_cancel, :ipn_return]

  verify :method => :post,
         :only => [ :add_credit, :ipn_notify, :ipn_return, :worldpay_notify, :complete_photo_order,
                    :sell_credit, :invoice_us ],
         :redirect_to => { :controller => 'Account', :action => :index }

  def cart
    @cart = (session[:order_id].to_i > 0) && logged_in? ? Order.cart(session[:order_id].to_i) : nil
  end

  def add_credit
    ActiveMerchant::Billing::Base.integration_mode = :test if Configuration.test_payment_processing
    if params[:commit] == 'paypal'
      @processor = :paypal
      @notify    = url_for(:only_path => false, :action => 'ipn_notify')
      @account   = Configuration.paypal_email
    elsif params[:commit] == 'worldpay'
      #test number:
      @processor = :worldPay
      @notify    = url_for(:only_path => false, :action => 'worldpay_notify')
      @account   = Configuration.worldpay_security_key
    else
      @order.errors.add_to_base('Please select a payment processing option when purchasing Credits') unless (credit.to_i >= 5)
    end
    #do it
    Order.transaction do
      @order = Order.new(params[:order])
      credit = @order.credit
      #check that we have at least minimum order credits
      @order.errors.add_to_base("Minimal order amount is #{Configuration.order_minimum_credit} credits") unless ( credit.to_f >= Configuration.order_minimum_credit.to_f)
      #
      if @order.errors.length > 0
        render :action => :credit
      else
        @order.user_id = current_user.id
        @order.customer_ip = request.remote_ip
        @order.status      = 2
        #add credit to order_item
        order_item = OrderItem.new(:item_type => 2, :qty => 1, :value => credit.to_i,
          :description => "#{credit.to_i.to_s} Credits")
        @order.order_items << order_item
        @order.save
        #notify client
        UserMailer.deliver_purchase_receipt(current_user, @order)
        #determine which gateway is selected then send
        render :action => :post, :layout => 'auto_post'
      end
    end
  end
  
  def invoice_us
    Order.transaction do
      @order = Order.new(params[:order])
      @order.purchase_order = 'None' if @order.purchase_order.blank?
      @user  = current_user
      #save user info
      @user.company         = params[:user][:company]
      @user.contact_name    = params[:user][:contact_name]
      @user.contact_number  = params[:user][:contact_number]
      @user.billing_address = params[:user][:billing_address]
      credit = @order.credit
      #validate entry
      @order.errors.add_to_base("Minimal order amount is #{Configuration.minimum_sale_value} credits") unless (credit.to_i >= Configuration.minimum_sale_value) 
      @user.errors.add('company', 'Please specify a Company Name') if @user.company.blank?
      @user.errors.add('contact_name', 'Please specify a contact name for this order') if @user.contact_name.blank?
      @user.errors.add('contact_number', 'Please specify a contact number for this order') if @user.contact_number.blank?
      @user.errors.add('billing_address', 'Please specify a Billing Address') if @user.billing_address.blank?
      #
      if (@order.errors.length > 0) || (@user.errors.length > 0)
        render :action => :credit 
        return
      end
      @user.save
      #
      @order.user_id     = current_user.id
      @order.customer_ip = request.remote_ip 
      @order.status      = 2
      @order.address     = @user.billing_address
      #add credit to order_item
      order_item = OrderItem.new(:item_type => 2, :qty => 1, :value => credit.to_i, 
        :description => "#{credit.to_i.to_s} Credits")
      @order.order_items << order_item
      @order.save
      #notify client
      UserMailer.deliver_purchase_order_receipt(current_user, @order)
      #notify admins of purchase order
      AdminMailer.deliver_purchase_order_placed(current_user, @order)
    end
  end
  
  def sell_credit
    user = User.find(current_user.id)
    #check that a valid number is supplied
    value = params[:sell].to_f
    if value > 0.0
      #check if this is more than current user's credit
      unless value > user.credits.to_f
        #check if this is greater than our minimal purchase quantity
        if value <= Configuration.minimum_sale_value
          #looks good... proceed
          Order.transaction do
            journal = Journal.pay_seller(user, value)
            #
            User.sell_credit(user,value)
            sale = SaleOrder.create_order(journal,user,value)
            CreditHistory.sell_credit(sale,journal,value)
            #notify client
            UserMailer.deliver_sale_receipt(user, sale)
            #notify admin
            AdminMailer.deliver_payment_request(user, sale)
            #looks good..... reload
            redirect_to :controller => 'orders', :action => :credit 
          end
        end
      else
        step_notice('<h3>Invalid value. The sale value is greater than the number of credits in your account.</h3>'+
          '<h3>Please press the back button and key in a value smaller to equal to the number of credits in your account</h3>')
      end
    end
  end
  
  def credit
    @page_title = 'View your Accounting Page'
    @order = Order.new
    @user  = current_user
  end

  #PayPal IPN
  #ipn_notify is solely used to buy credits. Purchases of other items (ie photos, collections, licenses and so on) are handled internally using the Credit
  def ipn_notify
    notify = Paypal::Notification.new(request.raw_post)
    #log
    logger.info("PAYPAL IPN - Received paypal IPN: #{request.raw_post}")
    #get order from paypal
    if notify.acknowledge 
      #is this a subscription IPN?
      if notify.subscription?
        sub_user  = User.find(notify.custom)
        host_plan = HostPlan.find(notify.item_id)
        #log it
        OrderLog::add_sub_log(sub_user, notify, request.raw_post)
        #
        if notify.subscription_payment && notify.complete?
          Order.transaction do
            journal = Journal.subscription_payment(sub_user, notify)
            SubscriptionHistory.subscription_payment(sub_user, journal, notify)
            Photo.check_hosting_plan_photo_pricing(sub_user, host_plan)
            Collection.check_hosting_plan_collection_price(sub_user, host_plan)
            User.subscription_payment(sub_user, host_plan, notify)
            SubscriptionFailure.clear_failure(sub_user)
            #
            logger.info("PAYPAL IPN - received subscription IPN Payment for user #{sub_user.login} #{notify.to_yaml}")
          end
        elsif notify.subscription_signup || notify.subscription_modify
          #TODO capture subscription start date from subscr_date? do we need this? or just capture sub pay received into last_sub_date
          sub_type = notify.subscription_signup ? 'Signup' : 'Modify'
          #
          AdminMailer::deliver_new_sub_or_modify(sub_user, sub_type, request.raw_post)
          UserMailer::deliver_new_or_modify_subscription(sub_user, sub_type, host_plan)
          # 
          logger.info("PAYPAL IPN - Received IPN Subscription signup or modify: #{request.raw_post}")
        elsif notify.subscription_cancelation || notify.subscription_failed || notify.subscription_eot  #TODO fix typo
          SubscriptionFailure.capture_failure(sub_user, host_plan, notify.subscription_date)
          AdminMailer::deliver_alert_sub_failure(sub_user, request.raw_post)
          User::subcription_cancellation(sub_user) #TODO fix typo
          #
          logger.info("PAYPAL IPN - Received IPN Subscription cancel or fail: #{request.raw_post}")
        elsif notify.subscription_eot
          SubscriptionFailure::capture_failure(sub_user, host_plan, notify.subscription_date)
          AdminMailer::deliver_subscription_eot(sub_user, request.raw_post)
          User::subcription_cancellation(sub_user)            
          #
          logger.info("PAYPAL IPN - Received IPN Subscription EOT: #{request.raw_post}")
        else
          #subscription tables not updating indicates a problem
          AdminMailer::deliver_alert_unhandled_sub_ipn(sub_user, request.raw_post)
          #
          logger.info("PAYPAL IPN - Received IPN Subscription type which was not a payment: #{notify.to_yaml}")
        end
        logger.debug("PAYPAL IPN - received subscription IPN #{sub_user.login} #{notify.to_yaml}")
        render :nothing => true
        return #bail here as no further processing necessary
      end
      #check for order
      @order = Order.find(notify.item_id)
      OrderLog::add_order_log(@order, notify, request.raw_post)
      #check order not closed or cancelled
      if not [3,4].include?(@order.status)
        if notify.complete?
          Order.transaction do
            #populate ledger if credit has been bought
            journal = Journal.buy_credit(@order, notify)
            #populate credit history table if credit has been bought
            CreditHistory.add_credit(@order,journal)
            #credit user account
            User.add_credit(@order.user, @order.total)
            UserMailer.deliver_order_complete(@order)
            #close order
            @order.gate_transaction = notify.transaction_id
            @order.status = 4
            @order.save
          end
        else
          logger.info("PAYPAL IPN - Received IPN not Completed. #{request.raw_post}")
          # <tt>Canceled-Reversal</tt>::
          # <tt>Denied</tt>::
          # <tt>Expired</tt>::
          # <tt>Failed</tt>::
          # <tt>In-Progress</tt>::
          # <tt>Partially-Refunded</tt>::
          # <tt>Pending</tt>::
          # <tt>Processed</tt>::
          # <tt>Refunded</tt>::
          # <tt>Reversed</tt>::
          # <tt>Voided</tt>::
        end
        #expire cache
        expire_left_block
      else
        if ['Canceled-Reversal','Partially-Refunded','Refunded','Reversed','Voided'].include?(notify.status)
          AdminMailer::deliver_ipn_cancellation(@order, request.raw_post)
        end
        logger.error("PAYPAL IPN - IPN received on a closed order. Date : #{Time.new}. Order: #{@order.id}. Dump: #{request.raw_post}")      
      end
    else
      logger.error("PAYPAL IPN - Failed to verify Paypal's notification on order #{@order.id}. Dump: #{request.raw_post}")
      @order.error_message = "Order failed to verify with Paypal. Logged on Datetime : #{Time.new}"
      @order.save
    end
    #always render nothing
    render :nothing => true
  end

  def worldpay_notify
    notify = WorldPay::Notification.new(request.raw_post)
    #log
    logger.info("Worldpay Return: #{request.raw_post}")
    #check for order
    @order = Order.find(notify.item_id)
    OrderLog::add_order_log(@order, notify, request.raw_post)
    #check order not closed or cancelled
    if not [3,4].include?(@order.status)
      if notify.complete?
        Order.transaction do
          #populate ledger if credit has been bought
          journal = Journal.buy_credit(@order, notify)
          #populate credit history table if credit has been bought
          CreditHistory.add_credit(@order,journal)
          #credit user account
          User.add_credit(@order.user, @order.total)
          UserMailer.deliver_order_complete(@order)
          #close order
          @order.gate_transaction = notify.transaction_id
          @order.status = 4
          @order.save
        end
      else
        logger.info("WorldPay transaction returned as cancelled on order #{@order.id}.")
        step_notice('<h2>Order Cancelled</h2>')
        return
      end
      #expire cache
      expire_left_block
    else
      step_notice("<h2>Unexpected Order Status. Pleaase contact support with order reference: #{@order.id}</h2>")
      AdminMailer::deliver_ipn_cancellation(@order, request.raw_post)
      return
    end
    render :action => :order_complete
  end
  
  def ipn_return
    notify = Paypal::Notification.new(request.raw_post)
    #get order from paypal
    if notify.item_id.blank? && (not notify.auth.blank?)
      #returning from subscription... sub ipn_return does not post transaction details.
      render :action => :order_sub_complete
    else
      @order = Order.find(notify.item_id)
      render :action => :order_complete
    end
  end
  
  def ipn_cancel
    notify = Paypal::Notification.new(request.raw_post)
    if notify.item_id.blank? && (not notify.auth.blank?)
       render :action => :order_sub_cancelled
    else
      #get order from paypal
      @order = Order.find(notify.item_id)
      @order.status = 3
      @order.save
      #
      render :action => :order_cancel
    end
  end
  
  def update_cart
    order = Order.find(params[:id])
    if (!order.is_complete) && (order.user_id == current_user.id)
      for form_item in params[:item]
        item = OrderItem.find(form_item[0])
        if item
          item.qty = form_item[1]
          if item.qty > 0
            item.save
          else
            item.destroy
          end
        end
      end    
    end
    render :partial => '/orders/update_cart_rows', :locals => {:items => order.order_items}
  end
  
  def add_collection_to_cart
    collection = Collection.find(params[:id])
    if collection && current_user
      Order.transaction do
        #retrieve from session if we have an active cart session
        order = get_order_from_session
        order.status      = 1
        order.customer_ip = request.remote_ip
        order.save
        #add only if not already in cart
        items = order.order_items.find_by_item_id(collection.id, :conditions => ['item_type = ?',3])
        if items
          items.qty += 1
          items.save
        else    
          order.order_items.create(:item_type => 3, :qty => 1, :description => "Coolection #{collection.name}",
            :item_id => collection.id, :value => collection.price)
        end
        session[:order_id] = order.id
      end
      #render carts block using ajax if not already visible
      render :update do |page|
        page.replace_html 'cart_block', :partial => '/orders/cart_block'
        page.alert('Collection added to your cart. Access your cart at the top right of the website')
      end
    end
  end
  
  def complete_photo_order
    @order = Order.find(params[:id])
    if @order.user_id == current_user.id
      if @order.total > current_user.credits
        flash[:info] = 'Order value exceeded account Credits. Please add additional Credits to your account.'
        redirect_to :action => :cart
      else  
        user = current_user
        Order.transaction do
          #create journal for each photo bought
          for item in @order.order_items.media_items
            journal = Journal.buy_photo(user, item)
            #add entry to credit histories
            CreditHistory.photo_purchase(@order, journal, item)
            #update user credits
            User.buy_photo(user, item)
            @order.status = 4
            @order.save
            #post process according to what was bought
            item.process_item_purchase(current_user)
          end
          #clear session
          session[:order_id] = nil
        end
        self.current_user = user
      end
    end
  end

end