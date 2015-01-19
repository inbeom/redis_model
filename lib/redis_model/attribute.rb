module RedisModel
  # Public: Implementations for instance-level Redis attributes for specified
  # class.
  #
  # Example:
  #
  #   class User < ActiveRecord::Base
  #     includes RedisModel::Attribute
  #
  #     redis_model_attribute :sign_in_count, :counter
  #   end
  #
  #   user = User.find(1)
  #   user.sign_in_count.incr
  #   user.sign_in_count.to_i # Now it is set to 1
  module Attribute
    # Internal: Provides helper for DSL for RedisModel attributes which are
    # defined in block of RedisModel::Attribute.redis_model_attributes method.
    class DefinitionHelper
      # Public: Returns class in which attributes are defined.
      attr_reader :klass

      # Public: Returns Hash of default options for attributes.
      attr_reader :default_options

      # Public: Defines a RedisModel attribute with given data type and name.
      #
      # attribute_name - Name of the attribute.
      # options        - Additional options for the attribute.
      #
      # Returns nothing.
      #
      # Signature
      #
      #   <data_type>(attribute_name, options)
      #
      # data_type - Data type.
      RedisModel::Schema::DATA_TYPES.each do |data_type, _|
        define_method(data_type) do |*args|
          column_name = args[0]
          options = args[1] || {}

          @klass.redis_model_attribute args.first, data_type, @default_options.merge(options)
        end
      end

      # Internal: Initializes new DefinitionHelper instance.
      #
      # klass   - Class in which attributes are defined.
      # options - Default options for attribute definitions.
      #
      # Returns newly instantiated RedisModel::Attribute::DefinitionHelper
      #   object.
      def initialize(klass, default_options)
        @klass = klass
        @default_options = default_options
      end
    end

    module ClassMethods
      # Public: Defines an instance-level attribute.
      #
      # attribute_name - Name of the attribute.
      # type           - Data type of the attribute.
      # options        - Additional options for the attribute definition.
      #                  :foreign_key - Foreign key used for the attribute.
      #
      # Returns nothing.
      def redis_model_attribute(attribute_name, type, options = {})
        Class.new(RedisModel::BelongedTo) do
          data_type type

          if options[:foreign_key]
            custom_key_label do |redis_model|
              redis_model.parent.send(options[:foreign_key])
            end
          else
            custom_key_label(&:parent_id)
          end
        end.tap do |klass|
          const_set(attribute_name.to_s.camelize, klass)
          define_redis_attribute_method(attribute_name, klass)
        end
      end

      # Public: Defines multiple instance-level attributes.
      #
      # block - A block contains definitions of multiple attributes.
      #
      # Example:
      #
      #   class User
      #     redis_model_attributes
      #   end
      #
      # Returns nothing.
      def redis_model_attributes(options = {}, &block)
        RedisModel::Attribute::DefinitionHelper.new(self, options).tap do |definition_helper|
          definition_helper.instance_eval(&block) if block_given?
        end
      end

      # Internal: Defines getter/setter method for specified attribute.
      #
      # attribute_name - Name of the attribute.
      # klass          - Class for the attribute.
      #
      # Returns nothing.
      def define_redis_attribute_method(attribute_name, klass)
        define_method(attribute_name) do
          klass.new(parent: self).to_value
        end

        define_method("#{attribute_name}=") do |value|
          klass.new(parent: self).set(value)
        end
      end
    end

    def self.included(klass)
      klass.extend ClassMethods

      if klass.respond_to?(:after_destroy)
        klass.after_destroy :clear_redis_model_attributes
      end
    end

    # Public: Clears attributes defined by RedisModel.
    #
    # Returns nothing.
    def clear_redis_model_attributes
      RedisModel::Schema.collection.each do |klass, _|
        if klass < RedisModel::BelongedTo && Object.const_get(klass.to_s.deconstantize) >= self.class
          self.send(klass.to_s.demodulize.underscore).del
        end
      end
    end
  end
end
