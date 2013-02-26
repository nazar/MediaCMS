class CreateSwatchColorJoin < ActiveRecord::Migration
  def self.up
    create_table :swatch_members  do |t|
      t.integer :swatch_id, :swatch_color_id, :position
    end
    add_index :swatch_members, :swatch_id
    add_index :swatch_members, :swatch_color_id
  end

  def self.down
    drop_table :swatch_members
  end
end
