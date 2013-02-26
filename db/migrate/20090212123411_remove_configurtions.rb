class RemoveConfigurtions < ActiveRecord::Migration

  def self.up
    #configurations table no longer needed
    CreateConfigurations.down
  end

  def self.down
    CreateConfigurations.up
  end
end
