class Order < ActiveRecord::Base

  include ActiveMerchant::Billing::Integrations
  
  #order_status
  #-1 - error
  # 1 - cart
  # 2 - gateway
  # 3 - cancelled
  # 4 - completed

  #order_type
  # 1 - photo
  # 2 - credits
  # 3 - collection
  # 4 - photo license
  # 5 - photo resolution

  #once a photo has multiple licenses it cannot be purchased as a type 1
   
  attr_protected :customer_ip, :status, :error_message, :updated_at, :created_at
  attr_accessor  :credit
#  attr_accessor :card_type, :cc_number, :cc_first_name, :cc_last_name, :exp_month, :exp_year, :credit_amount
  
#  validates_numericality_of :credit, :only_integer => true, :on => :create  
#  validates_size_of :order_items, :minimum => 1
#  validates_length_of :cc_first_name, :in => 2..50
#  validates_length_of :cc_last_name, :in => 2..50
#  validates_length_of :address_1, :in => 2..255
#  validates_length_of :city, :in => 2..255
#  validates_length_of :zip, :in => 2..255
#  validates_length_of :state, :in => 2..255
#  validates_length_of :country, :in => 7..20
#  validates_length_of :customer_ip, :in => 7..15
#  #validates_length_of :cc_number, :in => 13..19, :on => :create
#  validates_inclusion_of :exp_month, :in => %w(1 2 3 4 5 6 7 8 9 10 11 12), :on => :create
#  validates_inclusion_of :exp_year, :in => %w(2007 2008 2009 2010 2011 2012), :on => :create

  has_many :order_items
  has_many :order_logs
  
  belongs_to :user

  #class methods

  def self.media_type(media)
    case
      when media.is_a?(Photo)
        1
      when media.is_a?(Video)
        6
      when media.is_a?(Audio)
        7
    end
  end

  def self.extra_object_type(objekt)
    case
      when objekt.is_a?(MediaLicensePrice)
        4
      when objekt.is_a?(PhotoResolutionPrice)
        5
      end
  end
  
  def self.cart_items_count(order)
    if order
      return order.order_items.count
    else
      return 0
    end
  end
  
  def self.cart(order_id)
    Order.find(order_id) if order_id.to_i > 0
  end
  
  def self.pending_orders
    Order.find(:all, :conditions => 'status = 2 and purchase_order is not null')
  end

  #options[:resolution] - expects object
  #options[:licenses]   - expects an array of objects
  def self.add_media_to_order(order, media, ip, options={})
    options[:licenses] ||= [] #at least an empty array
    has_res_price = false
    #
    order.status      = 1
    order.customer_ip = ip
    order.save!
    #next check if any extra resolution prices or licenses have been added
    unless options[:resolution].blank?
      object = options[:resolution]
      #security check... check resolution belongs to this media object
      if media.is_one_of_my_resolutions(object)
        item = order.order_items.find_or_initialize_by_item_id_and_item_type(object.id, self.extra_object_type(object))
        item.attributes =  {:description => "Media '#{media.title}' at resolution #{object.width} x #{object.height}", :value => object.price, :qty => 0}
        item.qty += 1
        item.save!
        #
        has_res_price = true
      end
    end
    #photo cart item can either be a resolution or a photo price depending on a site's configuration...
    #if no res price saved then save the photo to cart
    unless has_res_price
      #add the media item
      item = order.order_items.find_or_initialize_by_item_id_and_item_type(media.id, Order.media_type(media))
      item.attributes = {:description => media.buy_description, :value => media.price, :qty => 0} if item.new_record?
      item.qty += 1
      item.save!
    end
    #finally do licenses
    unless options[:licenses].blank?
      for license in options[:licenses] do
        #security check... check license belongs to this media object
        if media.is_one_of_my_licenses(license)
          item = order.order_items.find_or_initialize_by_item_id_and_item_type(license.id, self.extra_object_type(license))
          item.attributes = {:description => "Media '#{media.title}' License - #{license.license.name}", :value => license.price, :qty => 0}
          item.qty += 1
          item.save!
        end
      end
    end  
    order
  end

  #instance methods

  
  def total
    order_items.inject(0) {|sum, n| n.value * n.qty + sum}
  end
  
  def is_complete
    status == 4
  end  
  
  def status_desc
    case status
      when 1; 'In Cart'
      when 2; purchase_order.blank? ? 'Gateway' : 'Pending Payment'
      when 3; 'Cancelled'
      when 4; 'Completed'
    end
  end

end
