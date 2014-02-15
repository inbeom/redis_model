# RedisModel

RedisModel provides various types of interfaces to handle values on Redis from
applications, mostly with ORM including ActiveRecord. RedisModel is highly
customizable and tries to avoid polluting name space of previously defined
classes and modules.

## Installation

Add this line to your application's Gemfile:

    gem 'redis_model'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redis_model

## Usage

To cover as many use cases as possible, RedisModel provides three different
interfaces to handle values on Redis.

### Configuration

Keys of values on Redis in concern of RedisModel objects have naming convention
consisted of four parts:

  - Application name (optional)
  - Environment (optional)
  - Class name converted to underscore notation
  - Custom key label (optional)

It is recommended to set proper application name and environment (which is set
automatically using environment variables) to separate key namespace between
other applications and environments. It can be configured upon initial
bootstrapping stage (e.g. Rails initializers):

    # In config/initializers/redis_model.rb:

    RedisModel::Base.config do |config|
      config.app_name = 'my_application' # Optional (recommended)
      config.environment = 'production' # Optional
      config.redis_url = 'redis://localhost:6379'
    end

### Standalone Usage

Classes inherit `RedisModel::Base` can handle single type of value on Redis.

    class SomeCounter < RedisModel::Base
      data_type :counter # Required
    end

All child classes inherit from `RedisModel::Base` must declare type of data
to handle. Available types include primitive Redis object types and some
helpers (sorted alphabetically):

  - `:counter`
  - `:float`
  - `:hash`
  - `:integer`
  - `:list`
  - `:set`
  - `:sorted_set`
  - `:string`
  - `:timestamp`

For detailed specifications for each data type, refer documentation on modules
corresponding to data typees under `redis_model/types`.

If RedisModel is configured as above, all instances of `SomeCounter` refers to
the same key (which is `(application name):(environment):some_counter`). Key
label associated with instances can be retrieved by invoking
`RedisModel::Base#key_label` method. If it is necessary, you can define custom
key label for instances as:

    class SomeCounter < RedisModel::Base
      attr_reader :id

      data_type :counter

      # Uses return value of SomeCounter#id as custom label
      custom_key_label &:id
    end

After defining `custom_key_label`, key labels of instances becomes:

    some_counter = SomeCounter.new.tap { |counter| counter.id = 1 }

    some_counter.key_label
    # => (application name):(environment):some_counter:1

Custom key label is useful if Redis values associated with instance attributes.
If it is needed to define multiple Redis values associated with an instance,
instance-level attributes will be more useful.

### Instance-level Attributes

Instances of classes mix in `RedisModel::Attribute` module can have multiple
number of attributes associated with values on Redis. Classes defined as models
in certain ORM can be a good example for this use case:

    class User < ActiveRecord::Base
      include RedisModel::Attribute

      # Defines an instance-level attribute wired to Redis value.
      redis_model_attribute :sign_in_count, :counter
    end

After defining `redis_model_attribute`, getter method for the attribute is
defined as instance method of the class.

    user = User.find(1)

    user.sign_in_count.to_i
    # => 0

    user.sign_in_count.incr

    user.sign_in_count.to_i
    # => 1

Internally, `redis_model_attribute` defines a class inherit from
`RedisModel::Base` having name of attribute converted to camel case. In this
case, it will be defined as:

    `User::SignInCount`

By this manner, Redis values referenced by the newly defined class has
consistent key label. By default, instance-level attributes use return value of
`#id` method of parent class as custom label. If it is required to use
different method of parent class as custom label, `:foreign_key` option should
be specified:

    class User < ActiveRecord::Base
      include RedisModel::Attribute

      # User#name will be used as custom label.
      redis_model_attribute :sign_in_count, :counter, foreign_key: :name
    end

In many cases, it is required to define multiple attributes in single parent
class. As DSL defining single attribute is quite verbose compared to what it
does, `RedisModel::Attribute` provides helper to make multiple definitions
cleaner:

    class User < ActiveRecord::Base
      include RedisModel::Attribute

      redis_model_attributes do
        counter :sign_in_count
        set :post_ids
        set :order_ids
      end
    end

### Class-level Attributes

Ocasionally class-level attributes used as global scope variables are required.
Although it can be obtained by defining new class inherit from
`RedisModel::Base`, defining class attributes is cleaner and more concise.

    class User < ActiveRecord::Base
      include RedisModel::ClassAttribute

      redis_class_attribue :registration_counter, :counter
    end

    User.registration_counter.to_i
    # => 0

    User.registration_counter.incr

    User.registration_counter.to_i
    # => 1

## Contributing

1. Fork it ( http://github.com/<my-github-username>/redis_model/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
