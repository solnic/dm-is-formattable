module DataMapper
  module Is
    module Formattable
      
      FORMATTERS = [ :textile, :markdown ]

      ##
      # Methods that should be included in DataMapper::Model.
      # Normally this should just be your generator, so that the namespace
      # does not get cluttered. ClassMethods and InstanceMethods gets added
      # in the specific resources when you fire is :formattable
      ##
      def is_formattable(options={})
        extend  DataMapper::Is::Formattable::ClassMethods
        include DataMapper::Is::Formattable::InstanceMethods
        
        @formattable_options = options = { 
          :by => :textile,
          :on => { :content_original => :content_formatted },
          :format_property => :format_with
        }.merge!(options)
        
        options[:on].each do |source, result|
          property source, DataMapper::Types::Text
          property result, DataMapper::Types::Text
        end
        
        property options[:format_property], DataMapper::Types::Enum[:textile, :markdown], 
          :nullable => false, :default => options[:by]
        
        before :save, :format_source!
      end

      module ClassMethods
        attr_reader :formattable_options
      end # ClassMethods

      module InstanceMethods
        def format_source!
          format = attribute_get(self.class.formattable_options[:format_property])
          
          self.class.formattable_options[:on].each do |source, result|
            next unless self.dirty_attributes.map{|a, v| a.name}.include?(source)
            
            markup = case format
              when :textile:
                RedCloth.new(attribute_get(source)).to_html
              when :markdown:
                BlueCloth.new(attribute_get(source)).to_html
              else
                raise Exception.new("Unknown format type: #{format}! Supported formatters are: #{FORMATTERS.join(', ')}")
              end
            
            attribute_set(result, markup)
          end
        end
      end # InstanceMethods

    end # Formattable
  end # Is
end # DataMapper
