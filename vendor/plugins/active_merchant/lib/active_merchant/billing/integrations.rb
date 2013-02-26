require 'active_merchant/billing/integrations/notification'
require 'active_merchant/billing/integrations/helper'
require 'active_merchant/billing/integrations/bogus'
require 'active_merchant/billing/integrations/chronopay'
require 'active_merchant/billing/integrations/paypal'
require 'active_merchant/billing/integrations/nochex'
require 'active_merchant/billing/integrations/world_pay'

# make the bogus gateway be classified correctly by the inflector
ActiveSupport::Inflector.inflections do |inflect|
  inflect.uncountable 'bogus'
end
