module RedisModel
  module Types
    # Internal: Methods needed for Float data type.
    module Float
      include RedisModel::Types::BaseValue

      # Public: Retrieves Float value stored in the key.
      #
      # Returns Float value stored in the key. nil if it does not exist.
      def to_f
        get && get.to_f
      end

      alias_method :to_value, :to_f
    end
  end
end
