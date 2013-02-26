class ConvertMigrationSchemaToRails21 < ActiveRecord::Migration
  def self.up
    values = select_values('select id from migrations_info')
    values.each {|value| execute("replace into schema_migrations VALUES('#{value}')")}
  end

  def self.down
  end
end
