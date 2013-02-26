class TabnavGenerator < Rails::Generator::Base
  attr_accessor :tabnav_name

  def initialize(*runtime_args)
    super(*runtime_args)
    if args[0].nil? 
      puts banner
    else
      @tabnav_name = args[0].underscore
    end
  end
  
  def manifest
    record do |m|
      if @tabnav_name 
        # directories.
        m.directory File.join('app/models')
        m.directory File.join('app/views/tabnav')
  
        # Tabnav class and tabnav partial
        m.template 'tabnav.rb',   File.join('app/models', @tabnav_name + '_tabnav.rb')
        m.template 'partial.rhtml',    File.join('app/views/tabnav', "_#{@tabnav_name}_tabnav.rhtml")
      end
    end
  end
  
  protected 
  
  def banner
  <<-EOF
Usage: #{$0} #{spec.name} TabnavClassName

Example: #{$0} #{spec.name} Main
will generate: ./app/views/tabnav/_main_tabnav.rhtml
               ./app/models/main_tabnav.rb
  EOF
  end
  
end