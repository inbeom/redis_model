module RedisModel
  class Intersected < RedisModel::Base
    attr_reader :key_label

    data_type :sorted_set

    def initialize(sets, seed = rand(256))
      @sets = sets
      @key_label = (@sets.map(&:key_label) + [DateTime.current.to_i, seed]).compact.join(':')
    end

    def generate(expire_in = nil)
      RedisModel::Base.connection.zinterstore @key_label, @sets.map(&:key_label)
      RedisModel::Base.connection.expire(@key_label, expire_in) if expire_in
    end
  end
end
