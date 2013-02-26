class Admin::BansController < Admin::BaseController

  active_scaffold :ban do |config|
    config.label = "Ban list"
  end  

end
