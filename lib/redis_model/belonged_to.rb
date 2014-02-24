module RedisModel
  # Internal: Base class for instance-level RedisModel attributes. Instances
  # of this object should have reference to parent object.
  class BelongedTo < RedisModel::Base
    attr_accessor :parent, :parent_id

    # Internal: Instantiates new RedisModel::BelongedTo object with given
    # options.
    #
    # options - Options for new object.
    #           :parent    - Parent object.
    #           :parent_id - ID of parent object.
    #
    # Returns newly instantiated RedisModel::BelongedTo object.
    def initialize(attrs = {}, options = {})
      @parent = attrs[:parent]
      @parent_id = attrs[:parent_id]
    end

    # Internal: ID of parent model.
    #
    # Returns ID of parent model.
    def parent_id
      @parent_id || @parent.id
    end
  end
end
