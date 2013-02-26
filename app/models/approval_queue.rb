class ApprovalQueue < ActiveRecord::Base
  
  belongs_to :approvable, :polymorphic => true

  named_scope :awaiting_approval, :conditions => 'approval_queues.actioned_by is null', :order => 'created_at'

  named_scope :find_by_approvable, lambda{|approvable|
    a_id = approvable.id; a_type = approvable.class.base_class.name
    {:conditions => ['approvable_id = ? and approvable_type = ? ', a_id, a_type]}
  }

  #class scopes

  def self.medias(klass = nil)
    if klass.nil?
      klass_condition = ''
    else
      klass_condition = klass == klass.base_class ? '' : "and medias.medias_type = '#{klass.name}'"
    end
    ApprovalQueue.scoped(:select => 'approval_queues.*', :conditions => ['approvable_type = ?', 'Media'],
                         :join => "inner join medias on medias.id = approvable_id #{klass_condition}'")
  end

  #class methods

  def self.add_media_to_approval_queue(media)
    ApprovalQueue.create( :uploaded_by => media.user_id, :approvable => media)
  end

  def self.find_or_add_approval_queue(approvable)
    ApprovalQueue.find_by_approvable(approvable).first || ApprovalQueue.add_media_to_approval_queue(approvable)
  end


  #instance methods

  def approve_object(user)
    obj = approvable_type.constantize.find_by_id approvable_id
    unless obj.nil?
      if obj.respond_to?('approved')
        obj.approved = true
        obj.approved_by = user
        obj.approved_on = Time.now
        obj.save!
      end
    end
  end

  def approvable_type=(sType)
    super(sType.to_s.constantize.base_class.to_s)
  end

  def reject_and_clear
    self.approved = false
    self.actioned_by = current_user.id
    self.actioned_at = Time.now
  end

  def show_in_queue
    self.actioned_by = nil
  end

end
