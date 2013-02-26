class PicturePromotions < ActiveRecord::Migration

  def self.up
    create_table "promotions", :force => true do |t|
      t.column "photo_id",       :integer
      t.column 'code',             :string, :limit => 75
      t.column 'user_email',       :string, :limit => 50
      t.column 'vendor_ref',       :string, :limit => 50 #ebay reference goes here
      t.column 'credits',          :float,  :default => 0.0
      t.column 'uses_remaining',   :integer, :default => 1
      t.column 'created_at',       :datetime
    end
    add_index(:promotions, :photo_id)
    add_index(:promotions, :code)
    add_index(:promotions, :vendor_ref)
    
    create_table 'promotions_users', :force => true do |t|
      t.column 'promotion_id',     :integer
      t.column 'user_id',          :integer
      t.column 'created_at',       :datetime 
    end
    
    add_index(:promotions_users, :promotion_id)
    add_index(:promotions_users, :user_id)
  end
  
  def self.down
    remove_index(:promotions, :picture_id)
    remove_index(:promotions, :code)
    remove_index(:promotions, :vendor_ref)
    remove_index(:promotions_users, :promotion_id)
    remove_index(:promotions_users, :user_id)

    drop_table('promotions_users')
    drop_table('promotions')
  end
  
end