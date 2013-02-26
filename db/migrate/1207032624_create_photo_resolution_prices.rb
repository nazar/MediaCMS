class CreatePhotoResolutionPrices < ActiveRecord::Migration
  def self.up
    create_table :photo_resolution_prices do |t|
      t.column :photo_id,                          :integer
      t.column :photo_resolution_price_default_id, :integer
      t.column :width,                            :integer
      t.column :height,                            :integer
      t.column :pixel_area,                        :integer
      t.column :price, :float
    end
    add_index(:photo_resolution_prices, :photo_id, {:name => 'prp_photo_id'})
    add_index(:photo_resolution_prices, :photo_resolution_price_default_id, {:name => 'prp_default_id'})
  end

  def self.down
    drop_table :photo_resolution_prices
  end
end
