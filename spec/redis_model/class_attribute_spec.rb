require 'spec_helper'
require 'redis_model/class_attribute'

class TestClass
  include RedisModel::ClassAttribute

  redis_class_attribute :something, :set
end

describe RedisModel::ClassAttribute do
  context '.redis_class_attribue' do
    it { expect(TestClass).to be_respond_to(:something) }
    it { expect(TestClass).to be_respond_to(:something=) }
    it { expect(TestClass.something).to be_kind_of(RedisModel::Base) }
  end
end
