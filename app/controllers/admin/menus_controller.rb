class Admin::MenusController < Admin::BaseController

  active_scaffold :menus do |config|
    config.label = "Navigation Menu Templates"
    config.list.columns = [:name, :description]
    config.create.columns = [:name, :description]
    config.update.columns = [:name, :description]
  end
  
end