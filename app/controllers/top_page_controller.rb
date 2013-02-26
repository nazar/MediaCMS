class TopPageController < ApplicationController

  helper :comments, :photos, :news

  def index
    if current_user
      @page_title = "#{Configuration.site_name}"
      render :action => :index
      expire_in_5_minutes
    else
      landing
    end
  end

  def landing
    @page_title = "Welcome to #{Configuration.site_name}"
    render :action => :landing, :layout => 'blank_page'
  end

  def enter
    @page_title = "#{Configuration.site_name}"
    render :action => :index
  end

end
