class AudioCategories < ActiveRecord::Migration

  def self.up
    create_table :categories_audios, :id => false do |t|
      t.column :audio_id, :integer
      t.column :category_id, :integer
    end
    add_index :categories_audios, :audio_id
    add_index :categories_audios, :category_id
  end

  def self.down
    drop_table :categories_audios
  end

end
