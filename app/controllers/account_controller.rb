class AccountController < ApplicationController

  require 'digest/md5'

  helper :tags, :licenses, :markup, :medias, :audios, :videos, :photos, :feed
  
  #require login for index
  before_filter :login_required, :except => [ :login, :signup, :about, :activate, :activate_email,
                                              :lost_password, :password_change, :photographers ]

  def index
    @account = self.current_user
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end
    
  def update
    user = User.find_by_id(params[:id])
    valid_request_object_do(user) do
      if user.id == current_user.id
        user.paypal_email = params[:account][:paypal_email]
      else
        logger.info("Alert. #{current_user.id} Attempted to modify #{user.id} details. IP #{request.remote_ip}")
      end
      redirect_to :action => 'index'
    end
  end
  
  def about
    @grapher = User.find_by_login(params[:id])
    if @grapher.nil?
      render :text => '<h1>No such account!</h1>', :layout => 'default'
      return 
    end
    condition = ['id in (select tag_id from taggings inner join medias on '+
                                             '        taggings.taggable_id = medias.id and medias.type = "Photo" and taggings.taggable_type = ? '+
                                             '        and medias.user_id = ?) '+
                                             'and taggings_count > 0', 'Media', @grapher.id ]
    @tags = Tag.find( :all, :conditions => condition, :limit => 100, :order => 'taggings_count DESC' )
    @tags = @tags.sort{|x,y| x.name <=> y.name }
    @max_count = Tag.maximum('taggings_count', :conditions => condition)
    @my_photo_comments = @grapher.latest_photo_comments
    @page_title = "Photographer profile page -  #{@grapher.pretty_name}"
  end
  
  def avatar
    if params[:file] != nil
      @avatar = Avatar.new(params[:file], current_user)
      if not @avatar.save
        flash[:avatar] = @avatar.error
      end
    else
      flash[:avatar] = 'No file specified'
    end
    user = current_user;
    user.avatar = @avatar.filename
    user.avatar_type = @avatar.content_type
    user.save
    redirect_to :action => 'index'
  end
  
  def password
    #TODO functional test
    return unless request.post?
    if User.authenticate(current_user.login, params[:old_password])
      @old_password = params[:old_password]
      if params[:password] == ''
        flash[:notice_password] = "Empty passwords not allowed."
        redirect_to :action => 'index'
        return
      end  
      if (params[:password] == params[:password_confirmation])
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]
        if not current_user.save
          flash[:notice_password] = "Password not changed. Contact admin"
        else
          flash[:notice_password] = "Password changed."
          @old_password = ''
        end
#        redirect_to :action => 'index'
#        return
      else
        flash[:notice_password] = "Password mismatch" 
      end
    else
      flash[:notice_password] = "Wrong old password" 
    end
    redirect_to :action => 'index'
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if self.current_user && self.current_user.activated? && self.current_user.active?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "Logged in successfully"
    else
      if self.current_user 
        if not current_user.activated?
          flash[:notice] = 'Your account has not been activated yet. Please follow the directions that were sent to your email address.' 
          return
        end
        if not current_user.active?
          flash[:notice] = 'Your account has been disabled. Please contact us for further asistance.' 
          return
        end
      else
        flash[:notice] = 'Invalid login. Please check your username and password'
      end
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    #must agree terms
    @user.errors.add('terms', 'Must agree the Terms of service')  if @user.terms == '0'
    #check for valid promotion code, if one entered
    unless params[:user][:promotion_code].blank?
      promotion = Promotion.membership_promotion(params[:user][:promotion_code])
      @user.errors.add('promotion_code', 'not valid') if (not promotion) && (params[:user][:promotion_code].length > 0)
    end
    User.transaction do
      @user.setup_new_user(params[:user][:login], params[:user][:password], params[:user][:email])
      #now attach to user to save chain
      @user.save
      unless @user.valid? 
        render :action => :signup
      else
        #process promotion
        promotion.process_free_membership(@user) if promotion
        #send welcome email AND activation link
        UserMailer.deliver_welcome_email(@user, @user.password)
        UserMailer.deliver_activate_account(@user)
        #
        session[:token] = @user.token
        #render activation page
        redirect_to :action => 'activate'
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def activate
    return unless request.post?
    @activate =  User.find_by_token(params[:code])  
    if !@activate
      step_notice('<h2>Invalid request<h2>')
      return
    end
    if @activate.activated
      step_notice('<h2>Your account has already been activated.<h2>')
      return
    end
    #check that the activation code matches the stored email address.
    if @activate.email == params[:email]
      @activate.activate_user
      @activate.save
      #
      session[:token] = nil
      #login and redirect to account page
      self.current_user = @activate
      #email admin
      AdminMailer.deliver_new_user(@activate)
      #
      redirect_back_or_default(:controller => '/account', :action => 'index')
    else
      step_notice('<h2>Invalid activation code. Please go back and check both your activation code and email address.</h2>')
    end
  end
  
  def activate_email
    @user = User.find_by_token(params[:id])
    if @user
      if !@user.activated
        @user.activated = true
        @user.active    = true
        @user.setup_default_notifications
        @user.save
        #
        self.current_user = @user
        #email admin
        AdminMailer.deliver_new_user(@user)        
        #
        redirect_back_or_default(:controller => '/account', :action => 'index')
      else
        step_notice('<h2>Your account has already been activated.<h2>')
        return      
      end
    else
      #tar pit against brute force attacks
      sleep 10
      msg = "Invalid activation code. Your IP #{request.remote_ip} has been logged."
      logger.info(msg)
      step_notice("<h2>#{msg}<h2>")
      return
    end
  end
  
  def lost_password
    return unless request.post?
    user = User.find_by_login(params[:login]) unless params[:login] == ''
    user = User.find_by_email(params[:email]) unless params[:email] == ''
    if user 
      token1 = Digest::MD5.digest(user.token)
      token2 = User.encrypt(user.token,"#{user.salt}--#{Configuration.md5key}--")
      #
      UserMailer.deliver_reset_password(user, token1, token2)
      #
      step_notice('<h3>An email was sent to your registerd email address with further instructions '+
                      'on resetting your password.</h3>'+
                      "<h3>We have logged that this request originated from #{request.remote_ip}</h3>")
    else
      step_notice('<h3>Could not find an account using the supplied username or email address.</h3>')
    end
    logger.info("Password reset request from #{request.remote_ip} for #{params[:login]}:#{params[:email]}")
    #tarpit
    sleep 5
  end
  
  def password_change
    return unless request.post?
    token = params[:id]
    user = User.find_by_md5_token(token)
    if user.length > 0
      user = user[0]
      #verify confirmation code
      token2 = User.encrypt(user.token,"#{user.salt}--#{Configuration.md5key}--")
      if token2 == params[:confirm_code]
        password      = String.random_string(5)
        user.password = password
        user.save
        #
        UserMailer.send_welcome_email(user, password)
        #
        step_notice('<h3>Your password has been reset and your new login detail have been sent to your registered email address.</h3>')
      else
        step_notice('<h3>Confirmation code does not match.</h3>')
      end
    else
      step_notice('<h3>Invalid token. Cannot proceed.</h3>')
    end
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_to :controller => 'TopPage', :action => 'index'
    flash[:notice] = "You have been logged out."
  end
  
  def send_message
    user = User.find(params[:user_id])
    if user
      UserMailer.deliver_email_member( user,
                                       current_user.email,
                                       params[:subject],
                                       Misc.format_red_cloth(params[:markup_message]))
    end                                    
  end
  
  #TODO move to own controller
  def photographers
    @photographers = User.active_members
  end  
  
end
