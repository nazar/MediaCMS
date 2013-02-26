class CorrectTablePlural < ActiveRecord::Migration
  def self.up
    rename_table(:promotions_emails, :promotion_emails)
    rename_table(:promotions_users, :promotion_users)
  end
  
  def self.down
    rename_table(:promotion_emails, :promotions_emails )
    rename_table(:promotion_users, :promotions_users )
  end
end