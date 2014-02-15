require 'redis_model/types/base'

module RedisModel
  module Types
    # Internal: Methods needed for string type.
    module String
      include RedisModel::Types::Base

      # Public: Reads value of string stored in Redis using GET command.
      #
      # Returns String contained in Redis. nil if it does not exist.
      def get
        @cached_value ||= RedisModel::Base.connection.get(key_label)
      end

      alias_method :to_s, :get

      # Public: Sets value of string stored in Redis using SEt command.
      #
      # value - Value to set.
      #
      # Returns String contained in Redis. nil if it does not exist.
      def set(value)
        @cached_value = nil

        RedisModel::Base.connection.set(key_label, value)
      end
    end
  end
end
