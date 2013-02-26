class Admin::PhotoResolutionPricesController < Admin::BaseController
  
  active_scaffold :photo_resolution_price_default do |config|
    config.label = "Photo Resolution Price Defaults"
    #override to set display order
    config.columns   = [:name, :description, :width, :height, :price]
  end  
  
end
