require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module WorldPay
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          def complete?
            status == 'Completed'
          end

          def account
            params['instId']
          end

          def item_id
            params['cartId']
          end

          def transaction_id
            params['transId']
          end

          # When was this payment received by the client.
          def received_at
            Time.at(params['transTime'].to_i / 1000)
          end

          # Callback password set in the WorldPay CMS
          def security_key
            params['callbackPW']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['authAmount']
          end

          def fee
            #TODO check if WP supplies this. If so then parse and return
            0.0
          end

          def currency
            params['authCurrency']
          end

          # Was this a test transaction?
          def test?
            params.key?('testMode') && params['testMode'] != '0'
          end

          def status
            params['transStatus'] == 'Y' ? 'Completed' : 'Cancelled'
          end

          def name
            params['name']
          end

          def address
            params['address']
          end

          def postcode
            params['postcode']
          end

          def country
            params['country']
          end

          def phone_number
            params['tel']
          end

          def fax_number
            params['fax']
          end

          def email_address
            params['email']
          end

          def card_type
            params['cardType']
          end

          # WorldPay extended fraud checks returned as a 4 character string
          #   1st char: Credit card CVV check
          #   2nd char: Postcode AVS check
          #   3rd char: Address AVS check
          #   4th char: Country comparison check
          # Possible values are:
          #   :not_supported   -  0
          #   :not_checked     -  1
          #   :matched         -  2
          #   :not_matched     -  4
          #   :partial_match   -  8
          def cvv_status
            return avs_value_to_symbol(params['AVS'][0].chr)
          end

          def postcode_status
            return avs_value_to_symbol(params['AVS'][1].chr)
          end

          def address_status
            return avs_value_to_symbol(params['AVS'][2].chr)
          end

          def country_status
            return avs_value_to_symbol(params['AVS'][3].chr)
          end

          def acknowledge
            return true
          end

          # WorldPay supports the passing of custom parameters through to the callback script
          def custom_params
            return @custom_params ||= read_custom_params
          end

          private

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            @raw = post
            for line in post.split('&')
              key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
              params[key] = value
            end
          end

          # Read the custom params into a hash
          def read_custom_params

            custom = Hash.new
            params.each do |key,value|
              if /\A(M_|MC_|CM_)/ === key
                custom[key.gsub(/\A(M_|MC_|CM_)/, '').to_sym] = value
              end
            end

            return custom

          end

          # Convert a AVS value to a symbol - see above for more about AVS
          def avs_value_to_symbol(value)

            case value.to_s
            when '8' then return :partial_match
            when '4' then return :no_match
            when '2' then return :matched
            when '1' then return :not_checked
            else return :not_supported
            end

          end

        end
      end
    end
  end
end
