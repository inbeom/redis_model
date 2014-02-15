require 'redis_model/base'

module RedisModel
  # Public: Implementations for class-level RedisModel attributes.
  #
  # Example:
  #
  #   class User < ActiveRecord::Base
  #     include RedisModel::ClassAttribute
  #
  #     redis_class_attribute :registration_count, :counter
  #   end
  #
  #   User.registration_count.incr
  #   User.registration_count.to_i # Now it is set to 1
  module ClassAttribute
    module ClassMethods
      # Public: Defines a RedisModel class attribute with given data type and
      # name.
      def redis_class_attribute(attribute_name, type)
        new_klass = Class.new(RedisModel::Base) do
          data_type type
        end

        const_set(attribute_name.to_s.camelize, new_klass)
        define_redis_class_attribute_method(attribute_name, new_klass)
      end

      def redis_class_attribute_classes
        @redis_class_attribute_classes ||= Hash.new
      end

      def define_redis_class_attribute_method(attribute_name, new_klass)
        singleton_class.class_eval do
          define_method(attribute_name) do
            new_klass.new.to_value
          end

          define_method("#{attribute_name}=") do |value|
            new_klass.new.set(value)
          end
        end
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
