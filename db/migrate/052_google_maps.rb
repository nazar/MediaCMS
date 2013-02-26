class GoogleMaps < ActiveRecord::Migration
  def self.up
    create_table "markers", :force => true do |t|
      t.column "markable_id",    :integer,     :null => false
      t.column "markable_type",  :string,      :limit => 50
      t.column "user_id",        :integer
      t.column "title",          :string,      :limit => 100
      t.column "long",           :decimal,     :scale => 8, :precision => 11
      t.column "lat",            :decimal,     :scale => 8, :precision => 11
      t.column "level",          :integer
      t.column "created_at",     :datetime
    end
    add_index(:markers, ['markable_id', 'markable_type'])
    add_index(:markers, 'user_id')
    add_index(:markers, 'long')
    add_index(:markers, 'lat')
  end 

  def self.down
    drop_table "markers"
  end
end
