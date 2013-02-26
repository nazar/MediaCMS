class FriendsController < ApplicationController
 
  verify :method => :post, :only => [ :create, :delete ]
 
  def new
    if current_user
      #session[:return_to] = request.request_uri
      #
      @user = User.find_by_login(params[:id])
      @friend = Friend.new
      render :layout => false
    else
      render :action => :register, :layout => false
    end
  end
  
  def create
    me = User.find(params[:me])
    friend = User.find(params[:them])
    
    Friend.add_friend(me, friend, params[:friend][:comments])
    render :update do |page|
      page.redirect_to session[:return_to]
    end
  end

  def delete
    my_row     = Friend.find(params[:id])
    friend_row = Friend.find(:first, :conditions => ['user_id = ? and friend_id = ?', my_row.friend_id, my_row.user_id])
    me         = User.find(my_row.user_id) 
    #delete both
    Friend.transaction do
      my_row.destroy;
      friend_row.destroy;
    end
    redirect_to :controller => 'account', :action => :about, :id => me.login
  end

  
end
