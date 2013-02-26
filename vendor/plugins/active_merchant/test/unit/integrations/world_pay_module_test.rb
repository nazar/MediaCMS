require File.dirname(__FILE__) + '/../../test_helper'

class WorldPayModuleTest < Test::Unit::TestCase

  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of WorldPay::Notification, WorldPay.notification('name=Andrew White')
  end
  
end 
