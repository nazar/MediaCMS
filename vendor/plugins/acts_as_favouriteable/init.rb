# Include hook code here
require 'acts_as_favouriteable'
ActiveRecord::Base.send(:include, PSP::Acts::Favouriteable)

require File.dirname(__FILE__) + '/lib/favourite'
