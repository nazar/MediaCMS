require 'net/http'

module ActiveMerchant
  module Billing
    module Integrations
      module Paypal
        # Parser and handler for incoming Instant payment notifications from paypal. 
        # The Example shows a typical handler in a rails application. Note that this
        # is an example, please read the Paypal API documentation for all the details
        # on creating a safe payment controller.
        #
        # Example
        #  
        #   class BackendController < ApplicationController
        #     include ActiveMerchant::Billing::Integrations
        #
        #     def paypal_ipn
        #       notify = Paypal::Notification.new(request.raw_post)
        #   
        #       order = Order.find(notify.item_id)
        #     
        #       if notify.acknowledge 
        #         begin
        #           
        #           if notify.complete? and order.total == notify.amount
        #             order.status = 'success' 
        #             
        #             shop.ship(order)
        #           else
        #             logger.error("Failed to verify Paypal's notification, please investigate")
        #           end
        #   
        #         rescue => e
        #           order.status        = 'failed'      
        #           raise
        #         ensure
        #           order.save
        #         end
        #       end
        #   
        #       render :nothing
        #     end
        #   end
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          # Overwrite this certificate. It contains the Paypal sandbox certificate by default.
          #
          # Example:
          #   Paypal::Notification.paypal_cert = File::read("paypal_cert.pem")
          cattr_accessor :paypal_cert
          @@paypal_cert = """
-----BEGIN CERTIFICATE-----
MIIDoTCCAwqgAwIBAgIBADANBgkqhkiG9w0BAQUFADCBmDELMAkGA1UEBhMCVVMx
EzARBgNVBAgTCkNhbGlmb3JuaWExETAPBgNVBAcTCFNhbiBKb3NlMRUwEwYDVQQK
EwxQYXlQYWwsIEluYy4xFjAUBgNVBAsUDXNhbmRib3hfY2VydHMxFDASBgNVBAMU
C3NhbmRib3hfYXBpMRwwGgYJKoZIhvcNAQkBFg1yZUBwYXlwYWwuY29tMB4XDTA0
MDQxOTA3MDI1NFoXDTM1MDQxOTA3MDI1NFowgZgxCzAJBgNVBAYTAlVTMRMwEQYD
VQQIEwpDYWxpZm9ybmlhMREwDwYDVQQHEwhTYW4gSm9zZTEVMBMGA1UEChMMUGF5
UGFsLCBJbmMuMRYwFAYDVQQLFA1zYW5kYm94X2NlcnRzMRQwEgYDVQQDFAtzYW5k
Ym94X2FwaTEcMBoGCSqGSIb3DQEJARYNcmVAcGF5cGFsLmNvbTCBnzANBgkqhkiG
9w0BAQEFAAOBjQAwgYkCgYEAt5bjv/0N0qN3TiBL+1+L/EjpO1jeqPaJC1fDi+cC
6t6tTbQ55Od4poT8xjSzNH5S48iHdZh0C7EqfE1MPCc2coJqCSpDqxmOrO+9QXsj
HWAnx6sb6foHHpsPm7WgQyUmDsNwTWT3OGR398ERmBzzcoL5owf3zBSpRP0NlTWo
nPMCAwEAAaOB+DCB9TAdBgNVHQ4EFgQUgy4i2asqiC1rp5Ms81Dx8nfVqdIwgcUG
A1UdIwSBvTCBuoAUgy4i2asqiC1rp5Ms81Dx8nfVqdKhgZ6kgZswgZgxCzAJBgNV
BAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMREwDwYDVQQHEwhTYW4gSm9zZTEV
MBMGA1UEChMMUGF5UGFsLCBJbmMuMRYwFAYDVQQLFA1zYW5kYm94X2NlcnRzMRQw
EgYDVQQDFAtzYW5kYm94X2FwaTEcMBoGCSqGSIb3DQEJARYNcmVAcGF5cGFsLmNv
bYIBADAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBBQUAA4GBAFc288DYGX+GX2+W
P/dwdXwficf+rlG+0V9GBPJZYKZJQ069W/ZRkUuWFQ+Opd2yhPpneGezmw3aU222
CGrdKhOrBJRRcpoO3FjHHmXWkqgbQqDWdG7S+/l8n1QfDPp+jpULOrcnGEUY41Im
jZJTylbJQ1b5PBBjGiP0PpK48cdF
-----END CERTIFICATE-----
"""

          # Was the transaction complete?
          def complete?
            status == "Completed"
          end

          # When was this payment received by the client. 
          # sometimes it can happen that we get the notification much later. 
          # One possible scenario is that our web application was down. In this case paypal tries several 
          # times an hour to inform us about the notification
          def received_at
            Time.parse params['payment_date']
          end

          # Status of transaction. List of possible values:
          # <tt>Canceled-Reversal</tt>::
          # <tt>Completed</tt>::
          # <tt>Denied</tt>::
          # <tt>Expired</tt>::
          # <tt>Failed</tt>::
          # <tt>In-Progress</tt>::
          # <tt>Partially-Refunded</tt>::
          # <tt>Pending</tt>::
          # <tt>Processed</tt>::
          # <tt>Refunded</tt>::
          # <tt>Reversed</tt>::
          # <tt>Voided</tt>::
          def status
            params['payment_status']
          end

          # Id of this transaction (paypal number)
          def transaction_id
            params['txn_id']
          end

          # What type of transaction are we dealing with? 
          #  "cart" "send_money" "web_accept" are possible here.
          #  subscription related messages are sent here. These are:
          #  subscr_signup: subscription sign-up.
          #  subscr_cancel: subscription cancellation.
          #  subscr_failed: subscription payment failure.
          #  subscr_payment: subscription payment.
          #  subscr_eot: subscription�s end-of-term.
          #  subscr_modify: subscription modification. 
          def type
            params['txn_type']
          end
          
          def subscription?
            ['subscr_signup', 'subscr_cancel', 'subscr_failed', 'subscr_payment', 'subscr_eot',
              'subscr_modify' ].include?(params['txn_type']) 
          end
          
          def subscription_date
            params['subscr_date']
          end
          
          def subscription_eff_date
            params['subscr_effective']
          end
          
          def subscription_signup
            params['txn_type'] == 'subscr_signup'
          end

          def subscription_modify
            params['txn_type'] == 'subscr_modify'
          end
          
          def subscription_cancelation
            params['txn_type'] == 'subscr_cancel'
          end
          
          def subscription_failed
            params['txn_type'] == 'subscr_failed'
          end

          def subscription_eot
            params['txn_type'] == 'subscr_eot'
          end

          def subscription_payment
            params['txn_type'] == 'subscr_payment'
          end
                    
          def subscription_subscriber_id
            params['subscr_id']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['mc_gross']
          end

          # the markup paypal charges for the transaction
          def fee
            params['mc_fee'] ? params['mc_fee'] : 0
          end

          # What currency have we been dealing with
          def currency
            params['mc_currency']
          end

          # This is the item number which we submitted to paypal 
          # The custom field is also mapped to item_id because PayPal
          # doesn't return item_number in dispute notifications
          def item_id
            params['item_number'] || params['custom']
          end

          def auth
            params['auth']
          end
          
          def custom 
            params['custom']
          end

          # This is the invoice which you passed to paypal 
          def invoice
            params['invoice']
          end   

          # Was this a test transaction?
          def test?
            params['test_ipn'] == '1'
          end

          # Acknowledge the transaction to paypal. This method has to be called after a new 
          # ipn arrives. Paypal will verify that all the information we received are correct and will return a 
          # ok or a fail. 
          # 
          # Example:
          # 
          #   def paypal_ipn
          #     notify = PaypalNotification.new(request.raw_post)
          #
          #     if notify.acknowledge 
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          def acknowledge      
            payload =  raw

            if test?
              ActiveMerchant::Billing::Base.integration_mode = :test
            else
              ActiveMerchant::Billing::Base.integration_mode = :production
            end

            uri = URI.parse(Paypal.service_url)
            request_path = "#{uri.path}?cmd=_notify-validate"

            request = Net::HTTP::Post.new(request_path)
            request['Content-Length'] = "#{payload.size}"
            request['User-Agent']     = "PantherFOTOS -- http://pantherfotos.com"

            http = Net::HTTP.new(uri.host, uri.port)

            http.verify_mode    = OpenSSL::SSL::VERIFY_NONE unless @ssl_strict
            http.use_ssl        = true

            request = http.request(request, payload)

            raise StandardError.new("Faulty paypal result: #{request.body} to #{Paypal.service_url} #{request_path}") unless ["VERIFIED", "INVALID"].include?(request.body)
            raise StandardError.new("Invalid paypal result: #{request.body} to #{Paypal.service_url} #{request_path} \n with request #{payload}") if ["INVALID"].include?(request.body)
            #logger.info("Paypal validate result: #{request.body}")

            request.body == "VERIFIED"
          end
        end
      end
    end
  end
end
