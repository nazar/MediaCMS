class PhotoLicensePriceToMedia < ActiveRecord::Migration

  def self.up
    rename_table 'photo_license_prices', 'media_license_prices'
    rename_column 'media_license_prices', 'photo_id', 'media_id'
  end

  def self.down
    rename_table 'media_license_prices', 'photo_license_prices' 
    rename_column 'photo_license_prices', 'media_id', 'photo_id'
  end

end
