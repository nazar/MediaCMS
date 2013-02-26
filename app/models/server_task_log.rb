class ServerTaskLog < ActiveRecord::Base
  
  belongs_to :server_task
  
  #class methods
  
  def self.log_success(task)
    ServerTaskLog.create(:server_task_id => task.id, :log => "#{task.task} completed successfully")
  end
  
  def self.log_exception(task, trace)
    if task 
      ServerTaskLog.create(:server_task_id => task.id, :log => "Task #{task.task} failed with trace #{trace}") if task.id
    else
      ServerTaskLog.create(:log => "Unknown task failed fataly with trace:\n#{trace}")
    end      
  end
  
  def self.trim_tables(dys = 14)
    self.delete_all(['created_at < ?',dys.days.ago])
  end
  
end
