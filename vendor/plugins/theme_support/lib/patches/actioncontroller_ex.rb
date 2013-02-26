# Extend the Base ActionController to support themes
ActionController::Base.class_eval do 

   attr_accessor :current_theme
   
   # Use this in your controller just like the <tt>layout</tt> macro.
   # Example:
   #
   #  theme 'theme_name'
   #
   # -or-
   #
   #  theme :get_theme
   #
   #  def get_theme
   #    'theme_name'
   #  end
   def self.theme(theme_name, conditions = {})
     # TODO: Allow conditions... (?)
     write_inheritable_attribute "theme", theme_name
   end

   # Set <tt>force_liquid</tt> to true in your controlelr to only allow 
   # Liquid template in themes.
   # Example:
   #
   #  force_liquid true
   def self.force_liquid(force_liquid_value, conditions = {})
     # TODO: Allow conditions... (?)
     write_inheritable_attribute "force_liquid", force_liquid_value
   end

   # Retrieves the current set theme
   def current_theme(passed_theme=nil)
     theme = passed_theme || self.class.read_inheritable_attribute("theme")
     
     @active_theme = case theme
       when Symbol then send(theme)
       when Proc   then theme.call(self)
       when String then theme
     end
   end
   
end

ActionController::Helpers::ClassMethods.class_eval do

 alias_method :__helper, :helper

 #override base helper to provide theme specific helpers.
 #Theme helpers are stored in RAILS_ROOT/themes/theme_name/helpers/theme_name_models_helper.rb
 #Theme override works with symbol helpers only. i.e. helper :photos
 def helper(*args, &block)
   args.flatten.each do |arg|
     case arg
     when Symbol
       #original  helper for the symbol
       __helper(arg, &block)
       #theme specific helper for rhe symbol
       theme = self.class.read_inheritable_attribute("theme")
       unless theme.blank?
         helper_sym = "#{theme}_#{arg.to_s}".to_sym
         helper_file = File.join(Theme.path_to_theme(theme), 'helpers', "#{helper_sym.to_s}_helper.rb");
         __helper(helper_sym, &block) if File.exists?(helper_file)
       end
     else
       __helper(arg, &block)
     end
   end
 end

 end