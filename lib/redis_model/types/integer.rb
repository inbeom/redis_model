module RedisModel
  module Types
    # Internal: Methods needed for Integer type.
    module Integer
      include RedisModel::Types::String

      # Public: Retrieves value stored in Redis key as Integer.
      #
      # Returns Integer value stored in Redis key, nil if it does not exist.
      def to_i
        get && get.to_i
      end

      alias_method :to_value, :to_i
    end
  end
end
