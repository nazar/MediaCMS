class Admin::RejectionReasonsController < Admin::BaseController
  
  active_scaffold :rejection_reason do |config|
    config.label = "Standard Rejection Reasons"
    #override to set display order
    config.columns   = [:name, :reason]
  end  

end
