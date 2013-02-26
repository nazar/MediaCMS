module Tabnav
  class Tab
    attr_reader :name, :image, :link, :highlights, :title, :condition, :submenus
    attr_accessor :highlighted, :parent, :first_tab, :last_tab
    
    def initialize &block
      @highlights  = []
      @submenus    = []
      @condition   = "true"
      @parent      = nil
      @highlighted = false
      @first_tab   = false
      @last_tab   = false
      instance_eval(&block);
    end
    
    def named name
      check_string name
      @name = name
    end  
    
    def imaged img
      @image = img
    end
    
    def submenu(name, link, options={})
      #TODO remove
      named name
      links = link.delete(:links_to)
      if links.kind_of? Hash
        links_to links
      else
        @link = links
      end
      if condition == options.delete(:conditions)
        show_if condition
      end
    end

    def has_submenu
      @submenus.length > 0
    end
    
    def add_submenu(sub)
      #TODO remove
      sub.parent = self
      @submenus << sub
    end
    
    def submenued(&block)
      raise "you should provide a block" if !block_given? 
      sub = Tab.new(&block)
      sub.parent = self
      @submenus << sub
    end
    
    def seperator
      '-'
    end
    
    def titled title
      check_string title
      @title = title
    end
      
    def links_to options={}
      check_hash options
      @link=options
      highlights_on options #my link will be highlighted too
    end
      
    def highlights_on options={}
      check_hash options
      @highlights << options
    end
    
    def show_if condition_string
      @condition = condition_string
    end
    
    # takes in input a Hash (usually params)
    def highlighted? options={}, method = {}
      result = false
      @highlights.each do |h| # for every highlight
        highlighted = method[:loose] ? false : true
        h.each_key do |key|   # for each key
          #remove / from h[key] if it is the first character
          comp_key = h[key].to_s.dup
          comp_key['/'] = '' if h[key].to_s['/']
          if method[:loose]
            highlighted |= comp_key == options[key].to_s   
          else
            highlighted &= comp_key == options[key].to_s   
          end            
        end 
        result |= highlighted
      end
      return result
    end
    
    private 
    
    def check_string param
      raise "param should be a String" if not param.kind_of? String
    end
    
    def check_hash param
      raise "param should be a Hash" if not param.kind_of? Hash
    end
    
        
  end
end
