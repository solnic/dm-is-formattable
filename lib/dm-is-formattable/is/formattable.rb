module DataMapper
  module Is
    module Formattable

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

      def is_formattable(options)

        # Add class-methods
        extend  DataMapper::Is::Formattable::ClassMethods
        # Add instance-methods
        include DataMapper::Is::Formattable::InstanceMethods

      end

      module ClassMethods

      end # ClassMethods

      module InstanceMethods

      end # InstanceMethods

    end # Formattable
  end # Is
end # DataMapper
