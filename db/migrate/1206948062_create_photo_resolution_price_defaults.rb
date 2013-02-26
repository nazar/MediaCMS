class CreatePhotoResolutionPriceDefaults < ActiveRecord::Migration
  def self.up
    create_table :photo_resolution_price_defaults do |t|
      t.column :name,          :string, :limit => 50
      t.column :description,   :text
      t.column :width,  :integer
      t.column :height,  :integer
      t.column :pixel_area,    :integer
      t.column :price,         :float
    end
  end

  def self.down
    drop_table :photo_resolution_price_defaults
  end
end
