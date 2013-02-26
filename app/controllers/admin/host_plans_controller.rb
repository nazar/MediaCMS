class Admin::HostPlansController < Admin::BaseController

  active_scaffold :host_plans do |config|
    config.label = "Hosting / Membership Plans" 
    config.columns = [:name, :description, :disk_space, :monthly_fee, :default_plan, :commerce, :blog, 
       :price_setting, :license, :club]
    config.list.columns = [:name, :disk_space, :monthly_fee, :default_plan, :commerce, :blog, 
       :price_setting, :license, :club] 
    config.show.columns = [:name, :description, :disk_space, :monthly_fee, :default_plan, :commerce, :blog, 
       :price_setting, :license, :club] 
  end  
end