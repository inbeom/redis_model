module RedisModel
  module Types
    # Internal: Base methods for helper types based on basic key-value pairs.
    module BaseValue
      include RedisModel::Types::Base

      # Public: Reads value of string stored in Redis using GET command.
      #
      # Returns String contained in Redis. nil if it does not exist.
      def get
        @cached_value ||= RedisModel::Base.connection.get(key_label)
      end

      # Public: Sets value of string stored in Redis using SEt command.
      #
      # value - Value to set.
      #
      # Returns String contained in Redis. nil if it does not exist.
      def set(value, options = {})
        @cached_value = nil

        RedisModel::Base.connection.set(key_label, value, options)
      end
    end
  end
end
