class CreateReportImageTypes < ActiveRecord::Migration
  def self.up
    create_table :report_image_types do |t|
      t.column :report_type, :string
      t.column :description, :text
      t.column :default_type, :boolean, :default => false
    end
  end

  def self.down
    drop_table :report_image_types
  end
end
