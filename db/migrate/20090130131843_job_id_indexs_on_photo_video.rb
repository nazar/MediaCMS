class JobIdIndexsOnPhotoVideo < ActiveRecord::Migration
  def self.up
    add_index :photos, :job_id
    add_index :videos, :job_id
  end

  def self.down
    remove_index :photos, :job_id
    remove_index :videos, :job_id
  end
end
