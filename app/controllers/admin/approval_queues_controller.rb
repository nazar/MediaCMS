class Admin::ApprovalQueuesController < Admin::BaseController
   
  helper :markup, :medias, :audios, :videos, :photos

  cache_sweeper :media_sweeper, :only => [ :approvee ]

  def index
    list
    render :action => 'list'
  end

  def list
   @media = ApprovalQueue.awaiting_approval.paginate :page => params[:page], :include => :approvable
   @reject_reasons = RejectionReason.find(:all, :order => 'name').map {|reason| [reason.name, reason.id]}
  end
  
  def approve
    page = params[:page] ? "?page=#{params[:page]}" : ''
    @queue = ApprovalQueue.find(params[:id])
    @queue.approved = true
    @queue.actioned_by = current_user.id
    @queue.actioned_at = Time.now
    @queue.save!
    #now do photo
    #approve polymorphic object
    @queue.approve_object(current_user)
    
    respond_to do |want|
      want.html {redirect_to "/admin/approval_queues#{page}"}
      want.js   {render :action => :remove_photo_row}
    end
  end
  
  def reject
    page = params[:page] ? "?page=#{params[:page]}" : ''
    @queue = ApprovalQueue.find(params[:id])
    reject_photo(@queue)
    @queue.save!
    #notify user
    UserMailer.deliver_photo_rejected(@queue)
    respond_to do |want|
      want.html { redirect_to "/admin/approval_queues#{page}" }
      want.js   {render :action => :remove_photo_row}
    end
  end
  
  def batch
    page = params[:page] ? "?page=#{params[:page]}" : ''
    @items = []
    #
    params[:photo].each do |key,value|
      #get item
      queue = ApprovalQueue.find(key)
      queue.actioned_by = current_user.id
      queue.actioned_at = Time.now
      #process
      case params[:Action]
      when "Reject Photos"
        reject_photo(queue)
        queue.save
        #notify user
        UserMailer.deliver_photo_rejected(queue)
      when "Approve Photos"
        queue.approved = true
        queue.save
        #notify user
        UserMailer.deliver_photo_approved(queue)
      end
      @items << queue.id
    end
    #complete
    respond_to do |want|
      want.html {redirect_to "/admin/approval_queues#{page}"}
      want.js
    end
  end
  
  def reason_text
    if request.xhr?
      render :update do |page|
        reason = RejectionReason.find(params[:reason])
        page["reject_reason[#{params[:id]}]"].value = reason.reason
      end
    end
  end
  
  protected
  
  def reject_photo(queue)
    queue.reject_and_clear
    #if rejection reason given then use it... otherwise use standard
    queue.rejecton_reason = params[:reject_reason][queue.id.to_s] ?  
      params[:reject_reason][queue.id.to_s] : RejectionReason.find(params[:reject_reason_select][queue.id.to_s])
    queue.photo.approved = false
    queue.photo.save
  end

  
end
