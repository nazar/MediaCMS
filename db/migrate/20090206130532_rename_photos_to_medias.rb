class RenamePhotosToMedias < ActiveRecord::Migration
  def self.up
    add_column :photos, :type, :string, {:limit => 15}
    #set type to Photo
    ActiveRecord::Base.connection.execute("update photos set type = 'Photo'")
    #
    rename_table(:photos, :medias)
    #rename photo_state and to state
    rename_column(:medias, :photo_state, :state)
    #
    add_column :medias, :duration, :integer, {:default => 0}
    add_column :medias, :bitrate, :integer, {:default => 0}
    #remove video table
    CreateVideos.down
  end

  def self.down
    rename_column(:medias, :state, :photo_state)
    #
    remove_column :medias, :type
    remove_column :medias, :duration
    remove_column :medias, :bitrate
    #
    rename_table(:medias, :photos)
    #
    CreateVideos.up
  end
end
