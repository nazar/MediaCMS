class PromotionLink < ActiveRecord::Migration
  def self.up
    add_column :promotion_emails, :token, :string, {:limit => 50}
    add_index :promotion_emails, :token
  end

  def self.down
    remove_column :promotion_emails, :token
  end
end
