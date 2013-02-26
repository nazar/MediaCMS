#Types: 0/null - simple text, 1- extended/blob text stores in setup_resources table, 2 - array
class Setup < ActiveRecord::Base

  has_one :setup_resource

  @cache = {}

  class << self; attr_reader :default_configuration; end

  #class methods

  def self.description(key)
    self.configuration[key][:description]
  end

  #iterate through confugrations keys and save existing values from params
  def self.assign_values(params)
    self.configuration.each do |key,value|
      val = %Q{params[key]}
      eval("Setup.#{key}=#{val}") unless params[key].nil?
    end
  end

  def self.blob?(key)
    self.configuration[key][:type] && self.configuration[key][:type] == 1
  end

  def self.configuration
    #TODO improve this. Ideally #Setup should not know about #Configuration
    Configuration.default_configuration
  end

  def self.configuration?(method)
    method = method.to_s =~ /=$/ ? method.to_s.chop! : method.to_s
    !self.configuration[method].blank?
  end

  def self.method_missing(method, args = nil)
    if self.configuration?(method)
      self.handle_configuration(method, args)
    else
      super(method, args)
    end
  end

  def self.handle_configuration(key, value)  
    key = key.to_s
    #assignment?
    if key =~ /=$/
      key.chop!
      type =  self.configuration[key][:type].blank? ? 0 : self.configuration[key][:type]
      Setup.set_key_value(key, value, type)
    else 
      Setup.get_key(key)
    end
  end
  
  def self.set_key_value(key, value, type = 0)
    setup = Setup.find_or_initialize_by_key(key)
    setup.save if setup.new_record?
    #
    case type
      when 0
        #value will always be String when submitted via a form. Preserve type by looking up the Setup default value,
        #if it exists, and determine the class type according to the default value
        setup.value_type = self.configuration[key][:default].nil? ? value.class.to_s : self.configuration[key][:default].class.to_s
        setup.value      = value
      when 1..2
        setup.save_blob_resource(value)
    end
    @cache[key] = self.convert_value_to_type(value, setup.value_type)
    setup.save
  end

  def self.get_key(key)
    unless @cache[key].nil? #is it cached?
      result = @cache[key]
    else
      result = Setup.find_by_key(key) #in the database?
      unless result.nil?
        result = Setup.blob?(key) ? result.setup_resource.value : result.typecasted_value
      else #not in database.. is there a default we can use?
        result = self.configuration[key][:default] unless result #get default
        #save to database as the default shouldn't be accessed multiple times (id MD5 will be regenerated as it defaults to a random string)
        Setup.set_key_value(key, result)
      end
    end
    @cache[key] = result
    result
  end

  def self.convert_value_to_type(value, value_type)
    return value if value_type.blank? || value.kind_of?(value_type.constantize) || value.nil?
    if    (value_type.constantize == TrueClass) || (value_type.constantize == FalseClass)  then %w[ true 1 t ].include?(value.to_s.downcase)
    elsif value_type.constantize == String     then value.to_s
    elsif value_type.constantize == Float      then value.to_f
    elsif value_type.constantize == Integer    then value.to_i
    elsif value_type.constantize == Fixnum     then value.to_i
    elsif value_type.constantize == BigDecimal then BigDecimal(value.to_s)
    elsif value_type.constantize == Class      then Object::find_const(value)
    else
      raise "unsupported type #{result.value_type}"
    end
  end

  #instance methods

  def save_blob_resource(value)
    if setup_resource
      self.setup_resource.value = value
      self.setup_resource.save
    else
      self.create_setup_resource({:value => value})
    end
  end

  def typecasted_value
    Setup.convert_value_to_type(value, value_type)
  end

  
end
