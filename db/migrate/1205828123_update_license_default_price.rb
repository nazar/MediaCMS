class UpdateLicenseDefaultPrice < ActiveRecord::Migration
  def self.up
    add_column(:licenses, :default_price, :float, {:default => '1.0'})
  end

  def self.down
    remove_column(:licenses, :default_price)
  end
end
