module RedisModel
  module Types
    # Internal: Methods for hash type of key in Redis.
    module Hash
      include Base

      # Public: Sets a key in Hash using Redis HSET command.
      #
      # key   - Key to set.
      # value - Value to set.
      #
      # Returns new value.
      def []=(key, value)
        result = connection.hset(key_label, key.to_s, value)

        @cached_hash = nil

        value
      end

      # Public: Retrieves a key in Hash using Redis HGET command.
      #
      # key   - Key to retrieve.
      #
      # Returns retrieved value.
      def [](key)
        connection.hget(key_label, key.to_s)
      end

      # Public: Increments a key in Hash using Redis HINCRBY command.
      #
      # key - Key to increment.
      # by  - Amount for increment (default: 1)
      #
      # Returns incremented value.
      def incr(key, by = 1)
        result = connection.hincrby(key_label, key, by)

        @cached_hash = nil

        result.to_i
      end

      def to_hash
        @cached_hash ||= connection.hgetall(key_label)
      end

      def keys
        connection.hkeys(key_label)
      end
    end
  end
end
