class MenuItem < ActiveRecord::Base

  #page types
  # 0: Not a link
  # 1: Built-in page
  # 2: Static page
  # 3: URL

  attr_accessor :highlighted, :first, :last, :cached_children

  belongs_to :menu

  validates_presence_of   :name
  validates_uniqueness_of :name, :case_sensitive => false, :scope => [:parent_id, :menu_id]

  acts_as_tree :order => 'position'

  named_scope :top_level, :conditions => 'parent_id is null'
  named_scope :default_items, :conditions => 'menu_id is null', :order => 'position ASC'
  named_scope :named_items, lambda {|menu| {:conditions => ['menu_id = ?',menu.id], :order => 'position ASC'}}

  before_save :assign_route
  after_save  :clear_menu_cache

  @menu_cache = {}
  class << self; attr_accessor :menu_cache; end

  #class methods

  def self.link_types
    {'Static Text' => 0, 'System Page' => 1, 'Static Page' => 2, 'URL' => 3}
  end

  #get top_level menus and children by name and cache
  def self.get_cached_menu_by_name(params, menu = nil)
    menu_name = menu.nil? ? 'default' : menu.name
    if MenuItem.menu_cache[menu_name].nil?
      #cache empty, load top level menus and children into cache
      MenuItem.menu_cache[menu_name] = menu.nil? ? MenuItem.default_items.top_level : MenuItem.top_level.named_items(menu)
      MenuItem.menu_cache[menu_name].each do |menu_item| 
        menu_item.children.each{|sub| menu_item.cache_child(menu_name, sub) }
      end
    end
    #mark first and last for children
    MenuItem.menu_cache[menu_name].each do |menu_item|
      menu_item.mark_highlighted(params, name)
      if menu_item.has_submenues?
        menu_item.cached_children.first.first = true
        menu_item.cached_children.last.last   = true
      end
    end
    #
    MenuItem.menu_cache[menu_name]
  end

  #instance classes
  
  def cache_child(menu_name, item)
    self.cached_children ||= []
    self.cached_children << item unless self.cached_children.include?(item)
  end

  def link_type_desc
    MenuItem.link_types.index(link_type)
  end

  def menu_link
    if link_type == 2
      page = Page.find_by_id link_url
      "/pages/view/#{link_url}/#{page.name.to_permalink}"
    else
      link_url
    end
  end

  #is a local link if linking to static or system page
  def local_link?
    [1,2].include?(link_type)
  end

  #a #MenuItem is displayed if it is visible and condition is either blank or evaluates to true
  def display?
    visible && (conditions.blank? || ((!conditions.blank?) && (eval(conditions))))
  end

  def has_submenues?
    cached_children && (cached_children.length > 0)
  end

  #expects a :controller and :action in params.
  #check submenu first for a target. if not found then check against self
  def mark_highlighted(params, name)
    result = false
    if local_link?
      if cached_children && cached_children.length > 0
        cached_children.each do |sub_menu|
          #mark parent highlighted if a sub_menu is
          result = sub_menu.mark_highlighted(params, name)
          break if result
        end
        #no sub_menus match... check if menu itself matches (but only if no sub match found)
        result = matches_route?(params) unless result
      else
        result = matches_route?(params)
      end
    else
      result = false
    end
    self.highlighted = result
    result
  end

  def matches_route?(params)
    result = (controller == params[:controller]) && (action == params[:action])
    #if static page then match against the page id as well
    result = result && link_url.to_i == params[:id].to_i if (!params[:id].blank?) && (link_type == 2)
    result
  end

  protected

  #before save callback. populate controller and action columns if link is of types 1 (built-in page) or 2 (static page)
  def assign_route
    if link_type == 1
      #need to sanitise url if it contains an anchor (as is the case with the home page links)
      url = link_url.dup
      url[/#\w+/] = '' unless link_url.blank? || link_url[/#\w+/].nil?
      #
      r = ActionController::Routing::Routes
      r = r.recognize_path(url)
      #
      self.controller = r[:controller]
      self.action     = r[:action]
    elsif link_type == 2
      self.controller = 'pages'
      self.action     = 'view'
    else
      self.controller = ''
      self.action     = ''
    end
  end

  #clear menu cache when saving a menu_item
  def clear_menu_cache
    menu_name = menu_id.blank? ? 'default' : menu.name
    MenuItem.menu_cache.delete(menu_name) unless MenuItem.menu_cache.nil? || MenuItem.menu_cache[menu_name].nil?
  end

end
