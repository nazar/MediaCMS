require 'singleton'

module Tabnav 
  class Base 
    include Singleton
    attr_accessor :tabs 
    
    def self.add_tab &block
      raise "you should provide a block" if !block_given? 
      instance.tabs ||= []
      tab = Tabnav::Tab.new(&block)
      instance.tabs << tab
      tab
    end 
    
    def self.add_submenu(tab, &block)
      #TODO remove
      sub = Tabnav::Tab.new(&block)
      tab.add_submenu(sub)
      sub
    end
    
    #marks first and last visible elements
    def self.mark_first_last(ptabs, &block)
      ptabs.each do |ptab|
        if block.call(ptab)
          ptab.first_tab = true 
          break
        end
      end
      ptabs.reverse_each do |ptab|
        if block.call(ptab)
          ptab.last_tab = true
          break
        end
      end
    end
    
    #set all tabs highlighted to false
    def self.reset_highlights(ptabs)
      ptabs.each do |tab|
        tab.highlighted = false
        tab.submenus.each do |sub|
          sub.highlighted = false
        end
      end
    end
    
    def self.mark_highlighted(ptabs, params, &block)
      
      def self.iterate_tabs(stabs, params, options, &block)
        res = false
        stabs.each do |tab|
          if block.call(tab) && tab.highlighted?(params, options)
            tab.highlighted = true
            mark_first_last(stabs, &block)
            mark_first_last(tab.submenus, &block) if tab.has_submenu
            res = true
            break true
          end
        end
        return res
      end
      #
      raise "you should provide a block" if !block_given? 
      reset_highlights(ptabs)
      found = false
      #try to find subtab first then parent... if failed then return first main tab
      sub = first_highlighted_sub(ptabs, params, &block)
      if sub
        sub.highlighted = true
        sub.parent.highlighted = true
        #mark first and last on tabs 
        mark_first_last(ptabs, &block)
        mark_first_last(sub.parent.submenus, &block)
      else #find first main using controller and action combinations
        found = iterate_tabs(ptabs,params,{},&block)
        #if not found then search for first matching controller
        iterate_tabs(ptabs, params, {:loose => true}, &block) if not found
      end
    end
    
    def self.first_highlighted_sub(ptabs, params, sub = [], &block)
      ptabs.each do |tab|
        if tab.parent && block.call(tab) && tab.highlighted?(params)
          sub << tab
        else
          first_highlighted_sub(tab.submenus, params, sub, &block) if tab.has_submenu
        end
      end
      return sub.first
    end

    private 
    
    def initialize
      @tabs = []
    end
  end
end