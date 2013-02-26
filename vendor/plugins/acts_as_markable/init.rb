# Include hook code here
require 'acts_as_markable'
ActiveRecord::Base.send(:include, PSP::Acts::Markable)
