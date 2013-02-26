class CreateReportImages < ActiveRecord::Migration
  def self.up
    create_table :report_images do |t|
      t.column :report_type_id, :integer
      t.column :reported_by, :integer
      t.column :actioned_by, :integer
      t.column :reportable_id, :integer
      t.column :reportable_type, :string, :limit => 30
      t.column :description, :text
      t.column :action, :text
      t.column :actioned, :datetime
      t.column :created_at, :datetime
    end
    add_index :report_images, :reported_by
    add_index :report_images, :actioned_by
    add_index :report_images, :reportable_id
    add_index :report_images, :report_type_id
  end

  def self.down
    drop_table :report_images
  end
end
