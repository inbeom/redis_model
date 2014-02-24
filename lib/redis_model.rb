require 'singleton'
require 'time'

require 'redis'
require 'active_support/inflector'

require "redis_model/version"
require 'redis_model/configurations'
require 'redis_model/types/base'
require 'redis_model/types/base_value'
require 'redis_model/types/string'
require 'redis_model/types/counter'
require 'redis_model/types/list'
require 'redis_model/types/sorted_set'
require 'redis_model/types/float'
require 'redis_model/types/set'
require 'redis_model/types/hash'
require 'redis_model/types/timestamp'
require 'redis_model/types/integer'
require 'redis_model/schema'
require 'redis_model/base'
require 'redis_model/belonged_to'
require 'redis_model/attribute'
require 'redis_model/class_attribute'
require 'redis_model/intersected'

# Public: RedisModel provides various types of interfaces to handle values on
# Redis from applications, mostly with ORM including ActiveRecord. RedisModel
# is highly customizable and tries to avoid polluting name space of previously
# defined classes and modules.
module RedisModel
  def self.config
    (@configurations ||= RedisModel::Configurations.instance).tap do |configurations|
      yield configurations if block_given?
    end
  end
end
