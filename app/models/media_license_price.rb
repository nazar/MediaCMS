class MediaLicensePrice < ActiveRecord::Base 
  
  belongs_to :media
  belongs_to :license
  belongs_to :user

  named_scope :media_user_licenses, lambda{|media|
    {:conditions => ["media_id = ?", media.id], :order => 'price ASC', :include => :license}
  }
  
  #class methods
  
  def self.setup_media_licenses_for_media_and_user(media)
    all_lics   = License.all_licenses_for_user(media.user)
    # get hash
    media_lics = {}
    media.media_license_prices.each{|license| media_lics[license.license_id] = license.price }
    # want to check if this media already includes license prices... and merge any new license types into existing entries
    all_lics.each do |license|
      # create only if not exists
      if media_lics[license.id].nil?
        MediaLicensePrice.create(:media_id => media.id, :user_id => media.user_id,
          :license_id => license.id, :price => license.default_price)
      end  
    end
  end

  # save license price against given photo. Expects photo and a hash of key => license.id, value => license price
  def self.save_media_license_prices(photo, prices)
    if prices && prices.size > 0
      prices.each do |key, value|
        if value.to_i == -1
          MediaLicensePrice.delete(key)
        else
          self.update_or_create_media_license_price(photo, key, value.to_f)
        end
      end
    end
  end

  def self.update_or_create_media_license_price(photo, id, value)
    price = self.find(:first, :conditions => ['id = ?', id])
    if price
      price.price = value
      price.save
    else
      MediaLicensePrice.create(:media_id => photo.id, :license_id => id, :price => value)
    end
  end
  
  #instance methods
end
