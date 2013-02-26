class PromotionsEmailUpdate < ActiveRecord::Migration
  def self.up
    remove_column(:promotions, :user_email)
    add_column(:promotions, :strict, :boolean, {:default => false})
    
    create_table "promotions_emails", :force => true do |t|
      t.column 'promotion_id',       :integer
      t.column 'email',              :string, :limit => 50
      t.column 'claimed_date',       :datetime
      t.column 'created_at',         :datetime
    end
    add_index(:promotions_emails, :promotion_id)
  end
  
  def self.down
    add_column(:promotions, :user_email, :string, {:limit => 50})
    remove_column(:promotions, :strict)
    remove_index(:promotions_emails, :promotion_id)
    
    drop_table(:promotions_emails)
  end
end