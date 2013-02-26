module ActiveRecord
  module Acts #:nodoc:
    module Swatchable #:nodoc:
      
      def self.included(base)
        base.extend(ClassMethods)  
      end
      
      module ClassMethods

        DEFAULT_THRESHOLD     = 8
        DEFAULT_POS_THRESHOLD = 2

        def acts_as_swatchable(options = {}) 
          write_inheritable_attribute(:acts_as_swatchabe_options, {
            :file            => options[:file],
            :depth           => options[:depth],
            :limit           => options[:limit],
            :threshold       => options[:threshold],
            :pos_threshold   => options[:pos_threshold],
            :swatchable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          })

          class_inheritable_reader :acts_as_swatchabe_options

          has_one  :swatch, :as => :swatchable
          has_many :swatch_colors, :through => :swatch
          has_many :swatch_members, :through => :swatch, :order => 'position ASC'

          include ActiveRecord::Acts::Swatchable::InstanceMethods
        end

        #finds top colors for all of this class (i.e Photo.top_colors, plus min and max color counts..ie Photo.top_colors
        #options- :limit (defaults to 100) and :format (defaults to :array) - :format -> [:array, :object]
        def top_colors(options={})
          options[:limit]  ||= 100
          options[:format] ||= :array
          #
          colors = SwatchColor.top_swatch_colors_by_swatches_type( acts_as_swatchabe_options[:swatchable_type] ).all(:limit => options[:limit])
          if colors.length > 0
            min_count = colors.first.swatches_count
            max_count = colors.last.swatches_count
            #convert to array of hex colors to keep as objects?
            colors = colors.collect{|c| c.to_hex} if options[:format] == :array
            colors = colors.collect{|c| {:hex => c.to_hex, :count => c.swatches_count}} if options[:format] == :minimal
          else
            max_count = 0; min_count = 0; colors = [];
          end
          return colors, min_count, max_count
        end

        #returns swatchables that have a similar colour. Expects a SwatchMember id
        #this method should be more accurate as it tried to preserve the importance of the colors
        #options- :threshold, defaults to 10 unless specified when invoking acts_as_swatchable :threshold => 123
        #options- :limit, defaults to 10
        #member_id is the swatch color id
        def find_by_swatch_member(swatch_member_id, options={})
          options = self.process_default_options(options)
          type    = acts_as_swatchabe_options[:swatchable_type]
          #find similar colors then return swatchables_ids that have these colors
          ids = Swatch.swatachable_ids_by_type_and_member(type, SwatchMember.find_by_id(swatch_member_id), options)
          order = ids.blank? ? nil : "Field(id, #{ids.join(',')})"
          #instruct the class to find using returned IDs
          self.scoped(:conditions => {:id => ids}, :limit => options[:limit], :order => order) unless ids.blank?
        end

        #returns swatchables that have a similar colour. Expects a single or array of colors as #AABBCC
        #options- :threshold, defaults to 10 unless specified when invoking acts_as_swatchable :threshold => 123
        #options- :limit, defaults to nil
        def find_by_colors(color, position = 0, options={})
          options = self.process_default_options(options)
          type    = acts_as_swatchabe_options[:swatchable_type]
          #find similar colors then return swatchables_ids that have these colors
          ids = Swatch.swatachable_ids_by_type_and_color(type, color, position, options)
          order = ids.blank? ? nil : "Field(id, #{ids.join(',')})"
          self.scoped(:conditions => {:id => ids}, :limit => options[:limit], :order => order) unless ids.blank?
        end

        protected

        def process_default_options(options)
          #options can either be defined in params, when invoked by acts_as_swatchable :threshold or by DEFAULT_THRESHOLD
          options[:threshold]     ||= acts_as_swatchabe_options[:threshold]
          options[:pos_threshold] ||= acts_as_swatchabe_options[:pos_threshold]
          {:threshold => DEFAULT_THRESHOLD, :pos_threshold => DEFAULT_POS_THRESHOLD}.merge_if_override(options)
        end

      end
      
      module InstanceMethods
        
        DEFAULT_DEPTH = 4
        DEFAULT_LIMIT = 10
        
        #runs "convert" ImageMagick command to extract top colors using histogram
        #options- :colors, :depth, :limit and :file
        def extract_top_colors_from_file(options={})
          #options either provided here, or at acts_as_swatchable... if neither then fallback to defaults
          options[:depth]  ||= acts_as_swatchabe_options[:depth]  
          options[:limit]  ||= acts_as_swatchabe_options[:limit]  
          options[:file]   ||= file_from_class_definition
          #merge with defaults
          options = { :depth  => DEFAULT_DEPTH,
                      :limit  => DEFAULT_LIMIT}.merge_if_override(options)
          #
          command = "`convert #{options[:file]} +dither -colors #{options[:limit]}  -depth #{options[:depth]} -format %c histogram:info:-`"
          out = eval(command)
          Rails.logger.fatal "ImageMagick command (#{command} failed: Error Given #{$?}" if $? != 0
          #return empty array at least
          [].concat(out.scan(/#([A-F0-9]+)/).flatten[0..(options[:limit]-1)])
        end

        #
        def swatch_from_image(options={})
          file = options[:file] || file_from_class_definition
          raise ":file not specified" if file.blank?
          #
          if File.exists?(file)
            Swatch.transaction do
              swatch = Swatch.swatch_for_swatchable(self) || self.create_swatch
              swatch.swatch_members.clear  #clear existing members incase redoing
              #
              colors = extract_top_colors_from_file(options)
              colors.each do |rgb_color|
                swatch.add_if_not_exists(rgb_color, colors.index(rgb_color)+1)
              end
              #
              swatch.colors_count = colors.length
              swatch.save
            end
          else
            Rails.logger.fatal "File #{file} not found during swatchable.swatch_from_image"
          end
        end

        #Finds all colors for this swatchable object
        #options -> :format either of :hex -> #AABBCC, :raw -> AABBCC, :component -> rgb(123, 124, 125). Defaults to :hex
        def colors(options={})
          options[:format] ||= 'hex'
          #
          unless swatch.nil?
            swatch.swatch_colors.collect do |color|
              case options[:format]
                when 'hex'
                   "##{color.rgb}"
                when 'raw'
                  color.rgb
                when 'component'
                  "rgb(#{color.red},#{color.green},#{color.blue})"
              end
            end
          else
            []
          end
        end

        def similar_swatachables(options={})
          conditions = options.delete(:conditions)
          swatchables = []
          swatch_members.each do |swatch_member|
            swatchables << self.class.find_by_swatch_member(swatch_member.id, options).scoped(:select => "id",
                                                                                              :limit => options[:limit],
                                                                                              :conditions => conditions).collect{|item| item.id}
            swatchables = swatchables.flatten.uniq.select{|target| target != self.id}
            break if (options[:limit].to_i > 0) && (swatchables.length >= options[:limit].to_i)
          end
          swatchables = options[:limit].blank? ? swatchables : swatchables[0..options[:limit].to_i - 1] 
          order = swatchables.blank? ? nil : "Field(id, #{swatchables.join(',')})"
          self.class.scoped(:conditions => {:id => swatchables}, :limit => options[:limit], :order => order)
        end

        protected

        def file_from_class_definition
          raise ":file not specified at class level" if acts_as_swatchabe_options[:file].nil?
          eval(acts_as_swatchabe_options[:file]) 
        end

      end
    end
  end
end