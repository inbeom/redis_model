module RedisModel
  module Types
    # Internal: Methods needed for counter data type.
    module Counter
      include RedisModel::Types::BaseValue

      # Public: Atomically increments counter value using Redis command INCR or
      # INCRBY.
      #
      # by - Amount to increment by (default: 1).
      #
      # Returns Integer value of counter after increment.
      def incr(by = nil)
        by ? connection.incrby(key_label, by) : connection.incr(key_label)
      end

      # Public: Retrieves Integer value of counter.
      #
      # Returns Integer value of counter.
      def to_i
        (get || 0).to_i
      end
    end
  end
end
