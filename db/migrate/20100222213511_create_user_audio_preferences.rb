class CreateUserAudioPreferences < ActiveRecord::Migration
  def self.up
    create_table :user_audio_preferences do |t|
      t.integer :user_id
      t.integer :sample_length, :default => 0
      t.string :bitrate, :length => 10
      t.timestamps
    end
    add_index :user_audio_preferences, :user_id,  {:name => 'user_audio_preferences_user'}
  end

  def self.down
    drop_table :user_audio_preferences
  end
end
