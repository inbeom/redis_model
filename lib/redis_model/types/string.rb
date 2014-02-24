module RedisModel
  module Types
    # Internal: Methods needed for string type.
    module String
      include RedisModel::Types::BaseValue

      alias_method :to_s, :get
      alias_method :to_value, :get
    end
  end
end
