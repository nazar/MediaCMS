class PromotionEmailSalePrice < ActiveRecord::Migration
  def self.up
    add_column(:promotion_emails, :sale_value, :float, {:default => 0.0})
  end

  def self.down
    remove_column(:promotion_emails, :sale_value)
  end
end
