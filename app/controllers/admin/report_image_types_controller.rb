class Admin::ReportImageTypesController < Admin::BaseController

  active_scaffold :report_image_type do |config|
    config.label = "Report Image Categories"
    #override to set display order
    config.columns   = [:report_type, :default_type, :description]
  end  

end
