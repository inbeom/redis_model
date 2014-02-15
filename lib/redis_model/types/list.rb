module RedisModel
  module Types
    # Internal: Methods needed for List type.
    module List
      include RedisModel::Types::Base

      # Public: Fetches elements in Redis list as Array using LRANGE command.
      #
      # Returns Array containing elements in the list.
      def to_a
        connection.lrange key_label, 0, -1
      end

      # Public: Retrieves length of Redis list using LLEN command.
      #
      # Returns Integer containing length of the list.
      def count
        connection.llen key_label
      end

      alias_method :length, :count

      # Public: Retrieves a element in the list using LINDEX command.
      #
      # Returns String containing value of the specified element.
      def [](index)
        connection.lindex key_label, index
      end

      # Public: Pushes a element into the list using RPUSH command.
      #
      # Returns true.
      def <<(value)
        connection.rpush key_label, value
      end

      alias_method :push, :<<
    end
  end
end
