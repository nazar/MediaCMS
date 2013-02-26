class CreateLedgers < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.column :name,              :string, :limit => 100 
      t.column :code,              :string, :limit => 10
      t.column :open_balance,      :float, :default => 0
      t.column :open_balance_date, :datetime
      t.column :status,            :boolean, :default => 1
      t.column :description,       :text
      t.column :balance,           :float, :default => 0
    end
  end

  def self.down
    drop_table :ledgers
  end
end
