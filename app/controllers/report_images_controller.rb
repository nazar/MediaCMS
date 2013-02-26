class ReportImagesController < ApplicationController

  helper :markup
 
  def report_image
    @photo  = Photo.find(params[:id])
    @report = ReportImage.new
    unless @photo
      step_notice('Invalid Image Identifier')
      return
    end
    #expect either a get or ajax call
    respond_to do |format|
      format.html
      format.js
    end
  end

  def report_photo
    photo  = Photo.find(params[:photo_id])
    report = ReportImage.new
    report.attributes = params[:report]
    report.reported_by = current_user.id if current_user
    report.reportable_id = photo.id
    report.reportable_type = photo.class.to_s
    report.save!
    #notify admin
    AdminMailer.deliver_image_reported(photo)
    #expect either a get or ajax call
    respond_to do |format|
      format.html {redirect_to :controller => 'photos', :action => :details, :id => photo.id}
      format.js
    end
  end
  
end
