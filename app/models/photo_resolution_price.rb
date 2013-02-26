class PhotoResolutionPrice < ActiveRecord::Base
  
  belongs_to :photo
  belongs_to :photo_resolution_price_default
  
  before_create :set_pixel_area
  
  #class methods
  
  #create default photo prices on given photo based on default price setup
  def self.setup_photo_resolutions_for_photo_and_user(photo)
    #get smaller sizes only
    def_sizes = PhotoResolutionPriceDefault.photo_default_sizes(photo)
    #get existing photo resolution size prices
    photo_sizes = {}
    photo.photo_resolution_prices.each{|size| photo_sizes[size.photo_resolution_price_default_id] = size.price}
    newly_created = photo_sizes.blank?
    #check if this photo is assigned default sizes and prices. If not then create options for current resolution plus generate alternative resolutions
    prev_price = 0.0
    def_sizes.each do |default_size|
      unless photo_sizes[default_size.id]
        #add smaller size resolutions with correct aspect ratio
        photo_size = PhotoResolutionPrice.new(:photo_id => photo.id, :photo_resolution_price_default_id => default_size.id, :price => default_size.price)
        photo_size.set_size_to_correct_aspect_ratio(default_size, photo)
        #prevent successive photo resolution prices having the same price as a lower resolution
        photo_size.price = photo_size.price + prev_price if photo_size.price.to_f == prev_price
        photo_size.save!
        #
        prev_price = photo_size.price.to_f
      end
    end
    #finally... create the current size as the last option and estimate price based on resolution
    if newly_created
      best_default = PhotoResolutionPriceDefault.find_best_matching_default(photo)
      photo_size = PhotoResolutionPrice.new(:photo_id => photo.id, :photo_resolution_price_default_id => best_default.id, :price => best_default.price,
        :width => photo.width, :height => photo.height)
      #prevent highest res price equal to smaller size
      photo_size.price += 0.5 if photo_size.price == prev_price
      photo_size.save!
    end
  end
  
  #return resolution options for given photo sorted by resolution
  def self.photo_resolutions(photo)
    resolutions = self.find_all_by_photo_id(photo.id, :order => 'pixel_area', :conditions => 'price > -1', :order => 'price ASC')
    if resolutions.blank? && PhotoResolutionPriceDefault.count > 0
      self.setup_photo_resolutions_for_photo_and_user(photo)
      return self.find_all_by_photo_id(photo.id, :order => 'pixel_area', :conditions => 'price > -1', :order => 'price ASC')
    else
      resolutions
    end
  end
  
  #save resolution prices to given photo
  def self.save_photo_reslution_prices(photo, prices)
    if prices && prices.size > 0
      prices.each do |key, value|
        resolution = self.find_by_id(key)
        #injection check. Does this resolution actually belongs to this photo?
        if resolution.photo_id == photo.id
          resolution.price = value.to_f
          resolution.save
        end
      end
    end
  end
    
  #instance methods
  
  def set_size_to_correct_aspect_ratio(def_size, photo)
    aspect = photo.width.to_f / photo.height.to_f
    self.width  = def_size.width
    self.height  = (self.width.to_f / aspect).to_i
  end  
  
  private
  
  def set_pixel_area
    self.pixel_area = width * height
  end

  
end
