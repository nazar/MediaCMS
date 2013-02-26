class SwatchableGenerator < Rails::Generator::Base

  default_options :skip_migration => false

  def manifest
    record do |m|
      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "create_swatchable_tables"
      end
    end
  end

  protected

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-migration", "Don't generate migration file for this model")                { |v| options[:skip_migration] = v }
  end

end
