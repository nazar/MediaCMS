class Admin::ProtectorController < Admin::BaseController

  active_scaffold :protector_log do |config|
    config.label = "Crawler & DOS Detection Logs"
  end  
  
end
