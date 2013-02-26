class CreateSwatchColors < ActiveRecord::Migration
  def self.up
    create_table :swatch_colors do |t|
      t.column  :rgb, :string, :limit => 6
      t.integer :red, :green, :blue
      t.column  :swatches_count, :integer, :default => 0
      t.timestamps
    end
    add_index :swatch_colors, :rgb
    add_index :swatch_colors, :red
    add_index :swatch_colors, :green
    add_index :swatch_colors, :blue
  end

  def self.down
    drop_table :swatch_colors
  end
end
