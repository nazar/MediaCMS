class PhotoResolutionPriceDefault < ActiveRecord::Base

  has_many  :photo_resolution_prices
  
  before_create :set_pixel_area

  named_scope :photo_default_sizes, lambda { |photo|
    {:conditions => ['pixel_area < ?', photo.width * photo.height], :order => 'pixel_area asc'}
  }

  #class instances
  
  def self.find_best_matching_default(photo)
    #use pixel area to determine which size best fits this photo
    area = photo.width * photo.height
    self.find_best_matching_default_by_area(area)
  end
  
  def self.find_best_matching_default_by_area(area)
    min, max = self.get_min_max_for_size(area)
    #area closest to the current area wins
    if area < min.pixel_area
      return min
    elsif area > max.pixel_area
      return max
    else
      return (area - min.pixel_area) < (max.pixel_area - area) ? min : max
    end  
  end
  
  #price is determined by the highest x or y resolution of the given photo
  def self.get_resolution_based_price(photo)
    res = self.find_best_matching_default(photo)
    res.price
  end
  
  def self.get_resolution_based_price_by_area(area)
    res = self.find_best_matching_default_by_area(area)
    if res
      res.price
    else 
      0
    end
  end
  
  def self.get_min_max_for_size(area)
    #get lower bound for given size
    lower = PhotoResolutionPriceDefault.find(:first, :order => 'pixel_area Desc', :conditions => ['pixel_area <= ?', area])
    lower = PhotoResolutionPriceDefault.find(:first, :order => 'pixel_area Asc') if lower.nil?
    #
    upper = PhotoResolutionPriceDefault.find(:first, :order => 'pixel_area Asc', :conditions => ['pixel_area >= ?', area])
    upper = PhotoResolutionPriceDefault.find(:first, :order => 'pixel_area Desc') if upper.nil?
    return lower, upper
  end
  
  private
  
  def set_pixel_area
    self.pixel_area = width * height
  end
  
end
