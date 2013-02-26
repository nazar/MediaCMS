class UpdatePromotions < ActiveRecord::Migration
  def self.up
    rename_column(:promotions, :photo_id, :link_id)
    add_column(:promotions, :link_type, :string, {:limit => 20})
    #
    Promotion.update_all('link_type = 1')
  end

  def self.down
    rename_column(:promotions, :link_id, :photo_id)
    remove_column(:promotions, :link_type)
  end
end
