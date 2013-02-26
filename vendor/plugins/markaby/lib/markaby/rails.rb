module Markaby
  module Rails
    # Markaby helpers for Rails.
    module ActionControllerHelpers
      # Returns a string of HTML built from the attached +block+.  Any +options+ are
      # passed into the render method.
      #
      # Use this method in your controllers to output Markaby directly from inside.
      def render_markaby(options = {}, &block)
        render options.merge({ :text => Builder.new(options[:locals], self, &block).to_s })
      end
    end

    class ActionViewTemplateHandler < ActionView::TemplateHandler # :nodoc:
      def render(template)
        @markaby_template = Template.new(template.source)
        @markaby_template.render(@view.assigns.merge(template.locals), @view)
      end
    end
      
    class Builder < Markaby::Builder # :nodoc:
      def initialize(*args, &block)
        super *args, &block
        @assigns.each { |k, v| @helpers.instance_variable_set("@#{k}", v) }
      end
      
      def flash(*args)
        @helpers.controller.send(:flash, *args)
      end
    
      # Emulate ERB to satisfy helpers like <tt>form_for</tt>.
      def _erbout
        @_erbout ||= FauxErbout.new(self)
      end

      # Content_for will store the given block in an instance variable for later use 
      # in another template or in the layout.
      #
      # The name of the instance variable is content_for_<name> to stay consistent 
      # with @content_for_layout which is used by ActionView's layouts.
      #
      # Example:
      #
      #   content_for("header") do
      #     h1 "Half Shark and Half Lion"
      #   end
      #
      # If used several times, the variable will contain all the parts concatenated.
      def content_for(name, &block)
        @helpers.assigns["content_for_#{name}"] =
          eval("@content_for_#{name} = (@content_for_#{name} || '') + capture(&block)")
      end
    end
    
    Template.builder_class = Builder
    
    class FauxErbout < ::Builder::BlankSlate # :nodoc:
      def initialize(builder)
        @builder = builder
      end
      def nil? # see ActionView::Helpers::CaptureHelper#capture
        true
      end
      def method_missing(*args, &block)
        @builder.send *args, &block
      end
    end

  end
end

