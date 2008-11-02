module DataMapper
  module Is
    module Formattable
      
      FORMATTERS = [ :textile, :markdown ]

      ##
      # fired when your plugin gets included into Resource
      #
      def self.included(base)

      end

      ##
      # Methods that should be included in DataMapper::Model.
      # Normally this should just be your generator, so that the namespace
      # does not get cluttered. ClassMethods and InstanceMethods gets added
      # in the specific resources when you fire is :formattable
      ##

      def is_formattable(options={})
        extend  DataMapper::Is::Formattable::ClassMethods
        include DataMapper::Is::Formattable::InstanceMethods
        
        options.merge!({ 
          :by  => :textile,
          :format_property => :format_with, 
          :source_property => :content_original, 
          :result_property => :content_formatted })
      
        @formattable_options = options
        
        property options[:source_property], DataMapper::Types::Text
        property options[:result_property], DataMapper::Types::Text
        property options[:format_property], DataMapper::Types::Enum[:textile, :markdown, :wikitext], 
          :nullable => false, :default => options[:by]
        
        before :save, :format_source!
      end

      module ClassMethods
        attr_reader :formattable_options
        
        def format_property
          self.send(formattable_options[:format_property])
        end
        
        def source_property
          self.send(formattable_options[:source_property])
        end
        
        def result_property
          self.send(formattable_options[:result_property])
        end
      end # ClassMethods

      module InstanceMethods
        
        def format_source!
          unless new_record? || dirty_attributes.keys.include?(self.class.source_property)
            return
          end
          
          format = attribute_get(self.class.formattable_options[:format_property])
          
          result = case format
            when :textile:
              RedCloth.new(attribute_get(self.class.formattable_options[:source_property])).to_html
            when :markdown:
              BlueCloth.new(attribute_get(self.class.formattable_options[:source_property])).to_html
            else
              raise Exception.new("Unknown format type: #{format}! Supported formatters are: #{FORMATTERS.join(', ')}")
            end
            
          attribute_set(self.class.formattable_options[:result_property], result)
        end
        
      end # InstanceMethods

    end # Formattable
  end # Is
end # DataMapper
