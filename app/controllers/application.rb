# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  
  layout 'default'
  theme  :get_theme
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include BrowserFilters
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :correct_webkit_and_ie_accept_headers
  before_filter :login_from_cookie
  before_filter :dos_protection

  helper_method :current_user, :logged_in?, :admin?, :last_active
  
  helper 'render_blocks', 'menu_items', :search
  
  session :off, :if => proc { |request| Utility.robot?(request.user_agent) }
  
  class Utility
    def self.robot?(user_agent)
      user_agent =~ /(Baidu|bot|Bot|Google|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|Yahoo|MSNBot)/i
    end
  end

  protected

  def correct_webkit_and_ie_accept_headers
    ajax_request_types = ['text/javascript', 'application/json', 'text/xml']
    request.accepts.sort!{ |x, y| ajax_request_types.include?(y.to_s) ? 1 : -1 } if request.xhr?
  end
  
  def get_theme
    Configuration.theme
  end
  
  def dos_protection
    return if session[:testing]
    return if logged_in?
    return unless Configuration.anti_crawler
    return if request.user_agent =~ /Google/
    #
    if banned = Ban.check_for_bans(request)
      step_notice("<p>Your IP #{request.remote_ip} has been temporarily banned.</p><p>Ban reason: #{banned.reason}.</p>")
    elsif ProtectorHits.check_for_dos(request)
      render :nothing => true
    end
  end

  def get_ip_host(ip)
    begin
      a = Socket.gethostbyname(ip)
      res = Socket.gethostbyaddr(a[3], a[2])
      return res[0]
    rescue
      return ''
    end
  end
                                                                                                                                                        
  def admin?
    logged_in? && current_user.admin?
  end

  def expire_left_block
    expire_fragment( 'left_block' )
    #generally assume that when the left block expires expire the center block as well
    expire_center_block
    expire_more_photos
  end
  
  def expire_center_block
    expire_fragment( 'top_page')
  end

  def expire_more_photos
    expire_fragment( 'more_photos')
  end
  
  def expire_rss_feeds
    expire_fragment( 'news_feeds')
  end
  
  #TODO do in sweeper on callback
  def expire_in_5_minutes
    def expire
      expire_center_block
      expire_more_photos
      session[:last_refresh] = Time.now
    end
    #clear the top_page cache every five minutes.
    if session[:last_refresh]
      if session[:last_refresh] + 5.minutes < Time.now
        expire
      end
    else
      expire
    end
  end
  
  def last_active 
    session[:last_active] ||= Time.now.utc ; 
  end

  def valid_request_object_do(obj, message = 'Invalid Request', status = 401)
    unless obj.blank?
      yield if block_given?
    else
      render :text => message, :status => status
      #fake exception to capture stack trace
      begin
        raise "fake"
      rescue => detail
        Rails.logger.warn(["INVALID OBJECT REQUESTED", "Params: #{params.to_yaml}", detail.backtrace.join("\n")].join("\n"))
      end
    end
  end

  def check_forum_access(forum)
    restrict = false
    if (forum.club_id > 0) && (forum.access_level > 0)
      #restrictions apply...check
      if not (forum.club.club_user_level(current_user) >= forum.access_level)
        step_notice('<h4>Insufficient permissions to access this forum. You must be logged in to access club restricted forums.</h4>')
        restrict = true
      end
    end
    yield unless restrict or (not block_given?)
  end

  def can_admin?
    if admin?
      yield
    else
      render :text => 'Not authorised', :status => 404 #TODO replace with a better template page
    end
  end

  def get_order_from_session
    if session[:order_id].to_i > 0
      Order.find_or_initialize_by_id(session[:order_id], :user_id => current_user.id)
    else
      Order.new(:user_id => current_user.id)
    end
  end

  def search_bot_allowed_here
    raise "block require" unless block_given?
    unless Utility.robot?(request.user_agent)
      yield
    else
      render :nothing => true
    end
  end

  def step_notice(content)
    render :partial => 'shared/notice',
           :locals => {:content => content},
           :layout => true
  end
  
  
  

end
