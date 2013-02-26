require 'acts_as_taggable'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)

require File.join(File.dirname(__FILE__), '/lib/tagging')
require File.join(File.dirname(__FILE__), '/lib/tag')
require File.join(File.dirname(__FILE__), 'helpers/taggable_helpers')