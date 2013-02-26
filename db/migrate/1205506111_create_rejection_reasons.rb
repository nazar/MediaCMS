class CreateRejectionReasons < ActiveRecord::Migration
  def self.up
    create_table :rejection_reasons do |t|
      t.column :name, :string
      t.column :reason, :text
    end
  end

  def self.down
    drop_table :rejection_reasons
  end
end
