class MapsController < ApplicationController
  helper :photos
  
  verify :method => :post, :only => [ :add_marker, :remove_marker ],
         :redirect_to => { :action => :index }
         
  before_filter :login_required, :except => [ :index, :videos, :photos ]

  def index
    redirect_to :action => :photos
  end

  def videos
    @page_title = "Viewing Video Markers"
  end

  def photos
    @page_title = "Viewing Photo Markers"
  end
  
  def add_marker
    obj = params[:markable_type].constantize.find(params[:markable_id])
    if obj
      #can only add to own photos or if admin
      if (obj.user_id == current_user.id) or (admin?)
        if (params[:marker_long].length > 0) && (params[:marker_lat].length > 0)
          marker = Marker.create(:user_id => obj.user_id, :title => params[:marker_title],
                               :long => params[:marker_long], :lat => params[:marker_lat])
          obj.add_marker(marker)
        end
      end       
      #update view
      render :partial => '/maps/list', :locals => {:markable => obj}
    end
  end
  
  def remove_marker
    #should have a has in params called delete.
    to_delete = params[:delete];
    if to_delete.length > 0
      #check these markers belong to this object
      markable = params[:markable_type].constantize;
      markable = markable.find_by_id(params[:markable_id].to_i)
      if markable
        objs = markable.markers.find to_delete
        #can only delete own objects                                         
        objs.each{|m| m.destroy if (m.user_id == current_user.id) or (current_user.admin)} 
      end
      #render marker list
      render :partial => '/maps/list', :locals => {:markable => markable}
      return
    end 
    render :nothing => true
  end
  
end