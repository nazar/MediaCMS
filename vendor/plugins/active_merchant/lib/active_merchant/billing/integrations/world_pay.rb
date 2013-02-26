require File.dirname(__FILE__) + '/world_pay/helper.rb'
require File.dirname(__FILE__) + '/world_pay/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module WorldPay

        # Overwrite this if you want to change the WorldPay test url
        mattr_accessor :test_url
        self.test_url = 'https://select-test.worldpay.com/wcc/purchase'

        # Overwrite this if you want to change the WorldPay production url
        mattr_accessor :production_url
        self.production_url = 'https://select.worldpay.com/wcc/purchase'


        def self.service_url
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
          when :production
            self.production_url    
          when :test
            self.test_url
          else
            raise StandardError, "Integration mode set to an invalid value: #{mode}"
          end
        end
        

        def self.notification(post)
          Notification.new(post)
        end
      end
    end
  end
end
