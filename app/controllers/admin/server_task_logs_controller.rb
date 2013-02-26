class Admin::ServerTaskLogsController < Admin::BaseController

  active_scaffold :server_task_logs do |config|
    config.label = "Server Task Logs"
    config.columns   = [:created_at, :log]
  end  
  
  def show_log_detail
    log = ServerTaskLog.find(params[:id])
    render :text => log.log, :layout => true
  end
  
end
