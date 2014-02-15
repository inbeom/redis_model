module RedisModel
  # Public: Parent class for classes associated with Redis attributes. It
  # provides methods to manipulate values on Redis storage.
  class Base
    # Public: DSL which defines data type for classes extending
    # RedisModel::Base. It is mandatory for child classes to indicate data type
    # before manipulating Redis values.
    #
    # type - The Symbol indicating data type for the class.
    #
    # Examples
    #
    #   class Foo < RedisModel::Base
    #     data_type :counter # Defines data type for instances of Foo class.
    #   end
    #
    #   foo = Foo.new
    #   foo.incr
    #   foo.to_i # 1
    #
    # Returns nothing.
    def self.data_type(type, options = {})
      include RedisModel::Schema.register(self, options.merge(data_type: type))
    end

    # Public: Retrieves proper RedisModel::Schema object describes schema
    # information for class being referenced.
    #
    # Returns RedisModel::Schema object for the class or its direct ancestor,
    #   nil if schema was not found.
    def self.redis_model_schema
      @schema ||= RedisModel::Schema.find(self)
    end

    # Public: Global Redis connection object. It is initialized only once.
    #
    # Returns Redis connection for objects using RedisModel.
    def self.connection
      @@connection ||= Redis.new(url: RedisModel::Configurations.instance.redis_url)
    end

    def self.custom_key_label(&block)
      redis_model_schema.custom_key_label(&block)
    end

    # Public: Retrieves key label for instantiated object.
    #
    # Returns the String label for the object.
    def key_label
      self.class.redis_model_schema.key_label(self)
    end

    # Internal: Converts value stored in Redis to primitive Ruby object. It acts
    # as a helper method which converts getters for certain types of RedisModel
    # attributes to return primitive types.
    #
    # Returns the primitive value of the object if it is available.
    def to_value
      self
    end
  end
end
