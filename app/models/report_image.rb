class ReportImage < ActiveRecord::Base
  
  belongs_to :reportable, :polymorphic => true
  belongs_to :report_image_type, :foreign_key => 'report_type_id'
  belongs_to :reporter, :class_name => 'User', :foreign_key => 'reported_by'
  belongs_to :actioner, :class_name => 'User', :foreign_key => 'actioned_by'
  belongs_to :photo, :foreign_key => 'reportable_id'
  
  #class methods
  
  def self.reported_images
    self.find(:all, :include => [:photo, :report_image_type, :reporter], :order => 'report_images.created_at', :conditions => 'report_images.actioned is null')
#    self.find(:all, :select => 'report_images.*, p.id, p.title, p.filename, p.user_id, rit.report_type, u.name',
#                    :joins => 'inner join report_image_types rit on report_images.report_type_id = rit.id '  <<
#                             'inner join photos p on report_images.reportable_id = p.id and report_images.reportable_type = \'Photo\' ' <<
#                             'left join users u on report_images.reported_by = u.id',
#                    :order => 'report_images.created_at'
#                  
#    )
  end

  def self.delete_photo(report, reason)
    report.action      = reason ? reason : 'Ajax deleted photo'
    report.actioned_by = current_user.id
    report.actioned    = Time.now
    report.save!
  end
  
  def self.ignore_report(report, reason = '')
    report.action      = reason ? reason : 'Ajax delete report'
    report.actioned_by = current_user.id
    report.actioned    = Time.now
    report.save!
  end
  
  #instance methods
  
    
end
