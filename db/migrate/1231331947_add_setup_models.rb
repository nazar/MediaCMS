class AddSetupModels < ActiveRecord::Migration
  def self.up
    create_table "setup_resources", :force => true do |t|
      t.column "setup_id", :integer
      t.column "value",    :text
    end

    add_index "setup_resources", ["setup_id"], :name => "index_setup_resources_on_setup_id"

    create_table "setups", :force => true do |t|
      t.column "key",   :string
      t.column "type",  :integer
      t.column "value", :string,  :limit => 200
      t.column "value_type", :string, :limit => 20
    end
  end

  def self.down
    drop_table :setup_resources
    drop_table :setups

  end
end
