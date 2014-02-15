module RedisModel
  module Types
    # Internal: Provides methods for Redis commands related to plain key
    # operations and helpers.
    module Base
      # Public: Asserts existence of Redis key having the label using Redis
      # command ExiSTS.
      #
      # Returns true if key exists, false otherwise.
      def exists?
        connection.exists(key_label)
      end

      # Public: Removes Redis value associated with the key using Redis command
      # DEL.
      #
      # Returns 1 if key is deleted, 0 otherwise.
      def del
        connection.del(key_label)
      end

      alias_method :clear, :del

      # Public: Helper method for global Redis connection.
      #
      # Returns global Redis connection object.
      def connection
        RedisModel::Base.connection
      end
    end
  end
end
