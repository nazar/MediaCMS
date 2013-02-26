class Admin::ReportImagesController < Admin::BaseController

  helper :markup
  
  def index
    @reports = ReportImage.reported_images
    @report  = ReportImage.new
  end
  
  def view_report
    @report = ReportImage.find(params[:id])
    respond_to do |want|
      want.html
      want.js
    end
  end
  
  def close_detail_row
    if request.xhr?
      render :update do |page|
        page.remove "report_row_desc_#{params[:id]}"
      end
    end
  end

  def delete_image
    @report = ReportImage.find(params[:id])
    delete_report_image(@report)
    #
    respond_to do |want|
      want.html {redirect_to '/admin/report_images'}
      want.js   {render :action => :delete_report}
    end
  end
  
  def delete_report
    @report = ReportImage.find(params[:id])
    ReportImage.ignore_report(@report)
    respond_to do |want|
      want.html {redirect_to '/admin/report_images'}
      want.js
    end
  end
  
  def batch_process
#    raise params.to_yaml
    reports = params[:report_image] 
    reports.each do |key,value|
      report = ReportImage.find(key)
      case params[:Action]
        when 'delete photo'
          delete_report_image(report, params[:report][:description])
        when 'ignore report'
          ReportImage.ignore_report(report, params[:report][:description])
      end
    end
    redirect_to '/admin/report_images'
  end
  
  protected
  
  def delete_report_image(report, reason = '')
    ReportImage.transaction do
      ReportImage.delete_photo(report, reason)
      report.photo.destroy
    end
    
  end
  
end
