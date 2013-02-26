class CreatePhotoLicensePrices < ActiveRecord::Migration
  def self.up
    create_table :photo_license_prices do |t|
      t.column :photo_id, :integer
      t.column :license_id, :integer
      t.column :price, :float
      t.column :created_at, :datetime
      t.column :user_id, :integer
    end
    add_index(:photo_license_prices, :photo_id, {:name => 'plp_photo_id'})
    add_index(:photo_license_prices, :license_id, {:name => 'plp_license_id'})
    add_index(:photo_license_prices, :user_id, {:name => 'plp_user_id'})
  end

  def self.down
    drop_table :photo_license_prices
  end
end
