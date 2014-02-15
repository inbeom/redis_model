module RedisModel
  # Public: Schema information for RedisModel::Base-derived classes. It
  # contains information required to manipulate Redis data including data type
  # and key label.
  class Schema
    attr_reader :klass, :data_type, :data_type_module

    # Public: Data type label and their corresponding module responsible for
    # specified type.
    DATA_TYPES = {
      value: RedisModel::Types::Counter,
      counter: RedisModel::Types::Counter,
      list: RedisModel::Types::List,
      sorted_set: RedisModel::Types::SortedSet,
      float: RedisModel::Types::Float,
      set: RedisModel::Types::Set,
      hash: RedisModel::Types::Hash,
      string: RedisModel::Types::String,
      timestamp: RedisModel::Types::Timestamp,
      integer: RedisModel::Types::Integer
    }

    # Public: Exception class indicating some class tried to initiate data_type
    # when one of its direct ancestors already have initiated.
    class DuplicateDefinition < StandardError ; end

    # Public: Exception raised when invalid data_type label is provided.
    class UnknownType < StandardError ; end

    # Public: Global index of RedisModel::Schema objects.
    #
    # Returns the Hash of global schema index.
    def self.collection
      @collection ||= {}
    end

    # Public: Find schema information for specified class. It could be schema
    # defined for one of ancestors of the class.
    #
    # klass - Class to find schema.
    #
    # Returns RedisModel::Schema object for given class, nil if it does not
    #   exist.
    def self.find(klass)
      collection[(klass.ancestors - klass.included_modules).detect do |parent_klass|
        collection[parent_klass]
      end]
    end

    # Public: Register schema for specified class.
    #
    # klass   - Class to register schema.
    # options - Additional options for schema.
    #           :data_type - Data type of Redis value.
    #
    # Returns the Module corresponding to data type of the class.
    def self.register(klass, options = {})
      raise DuplicateDefinition.new if find(klass)

      (collection[klass] = new(options.merge(klass: klass))).data_type_module
    end

    # Public: Initializes a Schema.
    #
    # options - Options for schema.
    #           :klass     - Class being specified for the schema.
    #           :data_type - Data type of Redis value.
    #
    # Returns newly initialized Schema object.
    def initialize(options = {})
      raise UnknownType.new unless DATA_TYPES[options[:data_type]]

      @klass = options[:klass]
      @data_type = options[:data_type]
      @data_type_module = DATA_TYPES[@data_type]
    end

    # Public: Key label of Redis value associated with instance of classes
    # inherit RedisModel::Base.
    #
    # object - Instance of RedisModel::Base-derived class.
    #
    # Returns String containing label for specified object.
    def key_label(object)
      [base_key_label, @custom_key_label_proc && @custom_key_label_proc.call(object)].compact.join(':')
    end

    # Public: Defines custom part of key label by passing a block having arity
    # of 1 to this method.
    #
    # block - Block or proc that converts object into custom label string
    #
    # Examples:
    #
    #   schema.custom_key_label do |object|
    #     object.id
    #   end
    #
    # Returns nothing.
    def custom_key_label(&block)
      @custom_key_label_proc = block
    end

    protected

    # Internal: Retrieves string used for label for Redis value associated with
    # the schema. Base label can be 
    #
    # Returns String containing base label.
    def base_key_label
      @key_label_base ||= [RedisModel::Configurations.instance.app_name, RedisModel::Configurations.instance.environment, @klass.name.underscore].compact.join(':')
    end
  end
end
