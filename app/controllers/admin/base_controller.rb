class Admin::BaseController < ApplicationController

  #require login for index
  before_filter :login_required
  before_filter :check_admin

  protected

  def check_admin
    if current_user
      if current_user.admin
        return
      end
    end
    render :text => 'Not authorised to access this area.'
  end
  
  
end
