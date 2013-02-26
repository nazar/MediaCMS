module Admin::ServerTasksHelper
  def task_form_column(record, input_name)
    select('record', 'task', ServerTask.server_tasks)
  end
end
  