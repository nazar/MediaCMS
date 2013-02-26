require 'acts_as_swatchable'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Swatchable)

require File.join(File.dirname(__FILE__), 'patches/hash')
require File.join(File.dirname(__FILE__), 'lib/swatch')
require File.join(File.dirname(__FILE__), 'lib/swatch_color')
require File.join(File.dirname(__FILE__), 'helpers/swatchable_helpers')