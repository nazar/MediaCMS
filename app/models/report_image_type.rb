class ReportImageType < ActiveRecord::Base
  
  has_many :reported_images
  
  #class methods
  
  def self.ordered_types
    ReportImageType.find(:all, :order => 'report_type')
  end
  
  #instance methods
  
end
