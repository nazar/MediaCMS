class JobSpinner

  def self.spin_job (&block)
    JobSpinner.spin_job_queue
    block.call
  end

  #check for queue manager pid, if not exists or pid invalid, start the queue manager
  def self.spin_job_queue
    @spinner ||= JobSpinner.new
    @spinner.start_queue_manager unless @spinner.running
  end

  def initialize
    @pid_file = File.join(Rails.root,'tmp','fotoscms-queue-manager.pid')
    @manager = File.join(Rails.root,'script','fotocms-queue-manager-daemon')
    @manager_start = @manager + ' start'
    @manager_stop = @manager + ' stop'
  end

  def running
    File.exists?(@pid_file) && process_exists
  end

  def process_exists
    begin
      f = File.new(@pid_file, 'r')
      pid = f.read.strip.to_i
    rescue
      pid = 0
    ensure
      f.close
    end
    result = pid > 0
    if result
      begin
         result = Process.getpgid(pid)
      rescue Errno::ESRCH
         result = false
      end
    end
    result
  end

  def start_queue_manager
    `#{@manager_start}`
  end

  def stop_queue_manager
    `#{@manager_stop}`
  end

end