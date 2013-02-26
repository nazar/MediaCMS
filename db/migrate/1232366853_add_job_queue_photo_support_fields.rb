class AddJobQueuePhotoSupportFields < ActiveRecord::Migration
  def self.up
    #add photo_state field to indicate processing state
    add_column :photos, :photo_state, :integer, {:default => 0}
    add_column :photos, :job_id, :integer
    add_column :photos, :orig_file_ext, :string, {:limit => 10}
    add_column :photos, :state, :integer
    #update all photos to statue == DONE
    ActiveRecord::Base.connection.execute('update photos set photo_state=10')
    #update jobs table to add job titles
    add_column :jobs, :job_title, :string, {:limit => 100}
  end

  def self.down
    remove_column :photos, :photo_state
    remove_column :photos, :job_id
    remove_column :photos, :orig_file_ext
    remove_column :photos, :state
    #
    remove_column :jobs, :job_title
  end
end
