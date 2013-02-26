class Symbol
  # Converts :sample in a SampleWizard class
  def to_tabnav
    file_name = self.id2name + '_tabnav'
    safe_require file_name  
    eval(file_name.camelcase).instance
  end
  
  def safe_require file_name
    require "#{file_name}"
  rescue
    STDERR.puts "cannot require "#{file_name}"
    false
  end
end

