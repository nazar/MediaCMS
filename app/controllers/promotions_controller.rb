class PromotionsController < ApplicationController

  def index
    redirect_to '/'
  end

  def claim_code
    #TODO need better recover code here... also succeptable to brute force attack. 
    #begin
      @promotion_email = PromotionEmail.find_by_token(params[:id])
      @promotion       = @promotion_email.promotion
      #check if user exists.. if not create
      user = User.find_by_email(@promotion_email.email)
      if user #user exists, login and redirect to library
        if current_user && current_user.id != user.id
          step_notice('User mismatch error. Please contact support.')
          return
        else
          self.current_user = user
        end
      else #user doesn't exists... create, send email, login and redirect to library
        if !current_user
          user, password = User.create_from_email(@promotion_email.email)
          self.current_user = user
          #send welcome email
          UserMailer.deliver_welcome_email(user, password)
        end
      end
      #decrement promotion uses count, add detail record then link to user's library
      Promotion.transaction do
        @promotion.process_token(user)
        @promotion.save
      end  
      redirect_to :controller => 'account', :action => :library
    #rescue
    #  sleep 3
    #  logger.info("Invalid promotion code #{params[:id]} attempted from #{request.remote_ip}")
    #  render :text => 'Invalid Claim code.', :layout => true
    #end      
  end
  
end