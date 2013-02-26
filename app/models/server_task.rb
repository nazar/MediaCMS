require 'net/http'

class ServerTask < ActiveRecord::Base
  
  has_many :server_task_logs, :dependent => :destroy
  
  #class methods
  
  def self.server_tasks
    [
      'notify_member_expire_7', 'rebuild_top_page_cache', 'update_rss_feeds', 'rebuild_photos', 'rebuild_previews', 'rebuild_thumbs',
      'rebuild_videos', 'rebuild_audios', 'clear_session_files'
    ].sort
  end
  
  def self.due_tasks
    self.scoped(:conditions => ['(period is not null and ((next_run < ?) or (next_run is null))) or ' <<
                                '((next_run is null) and (completed is null))',Time.now])
  end
  
  def self.run(task)
    self.transaction do
      begin
        #do task.. these are defined in as protected methods towards the end of this class
        task.send(task.task)
        #update record
        task.completed    = true unless task.period && (task.period != '')
        task.completed_at = Time.now
        task.next_run     = Time.now + eval(task.period) unless task.period.blank?
        task.save!
        #
        ServerTaskLog.log_success(task)
      rescue => detail
        #something went wrong... save it in log
        #log_error(detail)
        ServerTaskLog.log_exception(task, detail.to_yaml << detail.backtrace.join("\n"))
        #TODO add retry period logic to stop tasks that generate exception to run every minute
      end
    end
  end
  
  # manual tasks to queue

  def self.run_server_tasks
    ServerTask.due_tasks.each{|task| ServerTask.run(task) }
  end
  

  protected 

  #server tasks
  
  #notify members that memberhips will expire in 7 days
  def notify_member_expire_7
    users, event = User.unpaid_membership_expires_in_7_days
    users.each do |user|
      UserMailer.deliver_membership_expires_in_7_days(user)
      User.add_email_event(user, event)
    end
  end
  
  #notify members that memberhips will expire in 1 day
  def notify_member_expire_1
    users, event = User.unpaid_membership_expires_in_1_day
    users.each do |user|
      UserMailer.deliver_membership_expires_in_1_day(user)
      User.add_email_event(user, event)
    end
  end
  
  #rebuild the top_page cache
  def rebuild_top_page_cache
    controller = ActionController::Base.new
    controller.expire_fragment( 'top_page')
    controller.expire_fragment( 'more_photos')
    controller.expire_fragment( 'left_block' )
    #load page to regenerate cache
    Net::HTTP.get 'pantherfotos.com'          #TODO extract from routes
  end

  def update_rss_feeds
    RssFeed.active.each do |feed|
      RssFeed.transaction do
        RssFeed.update_feed_from_source(feed)
        feed.purge_old_feed_items
      end
    end
  end

  def rebuild_photos
    Photo.find(:all).each do |photo|
      if File.exists?(photo.original_file)
        photo.create_preview_and_thumbnail_files
      end
    end
  end

  def rebuild_previews
    Photo.find(:all).each do |photo|
      if File.exists?(photo.original_file)
        preview_file = photo.preview_file
        photo.watermark_preview_file(preview_file) if Configuration.images_watermark
        photo.annotate_preview_file(preview_file) if Configuration.images_annotate
      end
    end
  end

  def rebuild_thumbs
    Photo.find(:all).each do |photo|
      if File.exists?(photo.original_file)
        photo.create_thumbnail_file
      end
    end
  end

  def rebuild_videos
    Video.find(:all).each do |video|
      if File.exists?(video.original_file)
        video.convert_to_flash_and_generate_splash
      end  
    end
  end

  def rebuild_audios
    Audio.find(:all).each do |audio|
      if File.exists?(audio.original_file)
        audio.convert_to_mp3
      end
    end
  end

  def clear_session_files
    sess_dir = File.join(Rails.root, 'tmp', 'sessions', '/')
    %x[find #{sess_dir} -mtime +3 -type f | xargs rm]
  end
  
end
