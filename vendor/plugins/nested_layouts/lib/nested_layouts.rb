module ActionView #:nodoc:
  module Helpers #:nodoc:
    module NestedLayoutsHelper
      # Binding is only required if we're running less than Rails 2.2
      BINDING_REQUIRED = !!((Object.const_defined?(:Rails) && Rails.respond_to?(:version) ?
          Rails.version : RAILS_GEM_VERSION) < '2.2.0')

      # Wrap part of the template into layout.
      # All layout files must be in app/views/layouts.
      def inside_layout(layout, &block)
        binding = block.binding if BINDING_REQUIRED

        #add support for theme_support plugin for Rails 2.1.2
        if controller.respond_to?('current_theme') && !controller.current_theme.blank?
          #the current theme may or may not override the requested layout. Check if it exists in the current theme
          dir = File.join(Rails.root, 'themes', controller.current_theme, 'views', 'layouts')
          #check if layout has been overridden in the theme... if not then default app/views/layouts
          theme_layout = Dir.entries(dir).detect { |a| /^#{layout}\./.match(a) }
          #
          raise "Could not file layout #{layout} in dir #{dir}" if theme_layout.blank?
          dir = File.join(Rails.root, 'app', 'views', 'layouts') unless File.exists?(File.join(dir, theme_layout))
        else #theme support plugin not installed... continue...
          dir          = File.join(Rails.root, 'app', 'views', 'layouts')
          theme_layout = Dir.entries(dir).detect { |a| /^#{layout}\./.match(a) }
        end

        @template.instance_variable_set('@content_for_layout', capture(&block))
        concat(
          @template.render(:file => File.join(dir, theme_layout), :user_full_path => true),
          binding
        )
      end

      # Wrap part of the template into inline layout.
      # Same as +inside_layout+ but takes layout template content rather than layout template name.
      def inside_inline_layout(template_content, &block)
        binding = block.binding if BINDING_REQUIRED

        @template.instance_variable_set('@content_for_layout', capture(&block))
        concat( @template.render( :inline => template_content ), binding )
      end
    end
  end
end
