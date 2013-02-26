class CreateSwatches < ActiveRecord::Migration
  def self.up
    create_table :swatches do |t|
      t.column :swatchable_id,   :integer
      t.column :swatchable_type, :string,  :limit => 20
      t.column :colors_count,    :integer, :default => 0
      t.timestamps
    end
    add_index :swatches, [:swatchable_id, :swatchable_type], {:name => 'swatches_fk'}
  end

  def self.down
    drop_table :swatches
  end
end
