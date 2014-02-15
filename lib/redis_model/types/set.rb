module RedisModel
  module Types
    # Internal: Methods needed for Set type.
    module Set
      include RedisModel::Types::Base

      # Public: Fetches elements in Redis set as Array using SMEMBERS command.
      #
      # Returns Array containing elements in the set.
      def to_a
        connection.smembers key_label
      end

      # Public: Retrieves length of Redis set using SCARD command.
      #
      # Returns Integer containing cardinality of the set.
      def count
        connection.scard key_label
      end

      alias_method :length, :count

      # Public: Pushes a element into the set using SADD command.
      #
      # Returns true.
      def <<(value)
        connection.sadd key_label, value
      end

      # Public: Removes a element from the set using SREM command.
      #
      # Returns true.
      def remove(value)
        connection.srem key_label, value
      end

      # Public: Picks a member among elements in the set using SRANDMEMBER
      # command.
      #
      # count - Number of elements to pick.
      #
      # Returns Array containing elements in the set randomly selected.
      def pick(count)
        RedisModel::Base.connection.pipelined do
          count.times do
            connection.srandmember(key_label)
          end
        end
      end

      # Public: Asserts value is included in the set using SISMEMBER command.
      #
      # Returns true if value is included in the set, false otherwise.
      def include?(value)
        connection.sismember key_label, value.to_s
      end
    end
  end
end
