module RedisModel
  module Types
    # Internal: Methods needed for timestamp type.
    module Timestamp
      include RedisModel::Types::BaseValue

      # Public: Reads value on Redis and converts it to timestamp.
      #
      # Returns Time object.
      def to_time
        Time.parse(get) rescue nil
      end

      alias_method :to_value, :to_time

      # Public: Sets ISO 8601 string of timestamp to Redis.
      #
      # timestamp - Timestamp to store.
      #
      # Returns nothing.
      def set(timestamp)
        super(timestamp.utc.iso8601)
      end
    end
  end
end
