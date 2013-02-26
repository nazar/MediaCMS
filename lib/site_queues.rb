module SiteQueues

  module Manager

    def write_log(log)
      puts "#{Time.now.to_s} - #{log}"
    end
    module_function :write_log

    ##DaemonManager manages a collection of #Daemons by:
    #1. Starting a Daemon when a job is available
    #2. Stopping a Daemon when no new jobs have arrived
    class DaemonManager

      attr_reader :daemons

      def initialize(queues)
        #sanity checks
        raise "Expected Queue Array but received #{queues.class.to_s}" unless queues.is_a? Array
        raise "Queue Array is empty. Must specify at least one queue" if queues.blank?
        @daemons = []
        @clean_counter = 0
        #lets do this
        queues.each do |queue_name|
          @daemons << SiteQueues::Queues::Daemon.new(queue_name)
        end
      end

      #periodically query the job table and manage #Daemons according to job availability.. run in loop
      def process
        begin
          #check each daemon's queue for any jobs... if found then signal the daemon, otherwise shutdown if idling
          @daemons.each do |daemon|  
            if job = Job.find(:first, :conditions => ['state = ? and queue = ?', 'pending', daemon.name], :order => 'id DESC')
              Manager.write_log("Daemon Manager found Job in queue '#{daemon.name}': #{job.worker_class}.#{job.worker_method} created #{job.created_at.to_s}")
              daemon.signal(job.id)
            else
              daemon.stop_if_idle
            end
          end
          clean_old_jobs
        rescue Exception => e
          Manager.write_log(['DaemonManager Process caught an Exception!', e.message, e.backtrace.join("\n")].join("\n\n"))
        end
      end

      #force kill all running daemons #Daemons
      def stop
        @daemons.each {|daemon| daemon.stop(true)}
      end

      #delete any job that is older than x days
      def clean_old_jobs
        @clean_counter += 1
        if @clean_counter > 1000
          Job.delete_all(['created_at < ? and state = ?', 2.days.ago, 'finished'])
          @clean_counter = 0
        end
      end

      def process_server_tasks
        ServerTask.due_tasks.each{|task| ServerTask.run(task) }
      end

      def threads_are_idle
        @daemons.inject(true){|idle, daemon| idle && daemon.is_idle(1.minute)  }
      end

    end
  end


  module Queues

    class Daemon

      attr_accessor :last_id, :name

      def initialize(name)
        #init private vars
        @name     = name
        @last_id  = 0
        @last_job = Time.now
        @status   = :initialized
        @pid      = 0
      end

      #1. Signal the #Daemon with the last job id
      #2. Ensure that #Daemon process is actually running
      def signal(id)
        @last_id  = id
        @last_job = Time.now
        start unless @status == :running
      end

      def is_idle(idle_mins)
        (@last_job + idle_mins) < Time.now
      end

      #stop daemon if it has been idle for a while
      def stop_if_idle(idle_mins = 1.minutes)
        stop if  is_idle(idle_mins)
      end

      #start and fork into a child process
      def start
        unless @status == :running
          ActiveRecord::Base.remove_connection
          #RubyEE write_on_copy optimisation
          GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
          #fork it!
          @pid = Process.fork do
            Signal.trap('HUP'){ Manager.write_log("forked process '#{@name}' recieved HUP signal. Exiting."); ActiveRecord::Base.remove_connection; exit!;}
            Manager.write_log("Started '#{@name}' job queue")
            ActiveRecord::Base.establish_connection
            loop do
              if job = Job.find(:first, :conditions => ["state='pending' and start_at <= ? and queue = ?", Time.now, @name],
                                :order => "priority desc, start_at asc")
                Manager.write_log("Daemon found Job #{job.id} in queue '#{@name}': #{job.worker_class}.#{job.worker_method} created #{job.created_at.to_s}")
                started = Time.now
                job.get_done!
                Manager.write_log("Job #{job.id} completed in #{(Time.now - started).to_s}")
              else
                Manager.write_log("BackgroundFu Queue #{@name}: Waiting for jobs...")
                sleep 10
              end
              #exit if we become detached
              if Process.ppid == 1
                Manager.write_log('Fork detached. Exiting')
                break
              end
            end
            ActiveRecord::Base.remove_connection
          end
          @status = :running
          ActiveRecord::Base.establish_connection
          Manager.write_log("Queue '#{@name}' forked with id #{@pid}")
        end
      end

      #kill fork
      def stop(force = false)
        state = 'unknown'
        if (@status == :running) && (@pid > 0)
          #don't kill if job is still running
          if (job = Job.find_by_id @last_id)
            state = job.state
            kill = ['finished', 'failed'].include? job.state
          else
            kill = true
          end
          #kill it!!!!!
          if kill || force
            Manager.write_log("Forced Stop '#{@name}' job queue with pid #{@pid}") if force
            Manager.write_log("Stopping '#{@name}' job queue with pid #{@pid}")
            Process.kill('HUP', @pid)
            Process.waitpid(@pid)
            Manager.write_log("Stopped '#{@name}' job queue with pid #{@pid}")
            @pid = 0
            @status = :stopped
          else
            #self destruct mechanism where the job will be killed after 5 minutes
            if (@last_job + 5.minutes) > Time.now
              Manager.write_log("Not killing queue '#{@name}' job #{@last_id} as it is still running with state #{state}")
            else
              Manager.write_log("Force killing queue '#{@name}' job #{@last_id} in state #{state} as it has been running for over 5 minutes")
              stop(true)
            end  
          end
        end
      end
      
    end


  end

end