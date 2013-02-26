class CreateJobs < ActiveRecord::Migration

   def self.up
    #polymorphic swatchable table
    create_table :swatches do |t|
      t.column :swatchable_id,   :integer
      t.column :swatchable_type, :string,  :limit => 20
      t.column :colors_count,    :integer, :default => 0
      t.timestamps
    end
    add_index :swatches, [:swatchable_id, :swatchable_type], {:name => 'swatches_fk'}

    #colors as rgb hex string and red, green and blue integer components.
    #swatch_colors could have been just named colors but decided to namespace it with swatch to avoid conflict
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

    #members join table for swatches and swatch_colors
    def self.up
      create_table :swatch_members  do |t|
        t.integer :swatch_id, :swatch_color_id, :position
      end
      add_index :swatch_members, :swatch_id
      add_index :swatch_members, :swatch_color_id
    end

  end

  def self.down
    drop_table :swatch_color_join
    drop_table :swatch_colors
    drop_table :swatches
  end
end
