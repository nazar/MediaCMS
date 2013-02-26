class CreateMediaAudioProperties < ActiveRecord::Migration

  def self.up
    create_table :media_audio_properties do |t|
      t.integer :audio_id
      t.integer :sample_length
      t.string :bitrate, :limit => 10
      t.timestamps
    end
    add_index :media_audio_properties, :audio_id, {:name => :media_audio_properties_audio} 
  end

  def self.down
    drop_table :media_audio_properties
  end

end
