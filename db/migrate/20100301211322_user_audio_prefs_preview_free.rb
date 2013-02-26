class UserAudioPrefsPreviewFree < ActiveRecord::Migration

  def self.up
    add_column :user_audio_preferences, :free_full_length, :boolean
  end

  def self.down
    remove_column :user_audio_preferences, :free_full_length
  end

end
