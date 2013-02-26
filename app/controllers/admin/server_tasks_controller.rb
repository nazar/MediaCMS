class Admin::ServerTasksController < Admin::BaseController

  active_scaffold :server_task do |config|
    config.label = "Server Tasks"
    config.list.columns   = [:task, :created_at, :completed, :completed_at, :period, :next_run]
    config.update.columns = [:task, :taskable_id, :period]
    config.create.columns = [:task, :taskable_id, :period]
  end  
  
end
