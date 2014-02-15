require 'spec_helper'
require 'redis_model/helpers/sorted_set_paginator'

describe RedisModel::Helpers::SortedSetPaginator do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:sorted_set) { klass.new }
  let(:paginator) { RedisModel::Helpers::SortedSetPaginator.new(sorted_set) }

  before { klass.data_type :sorted_set }
  before { (1..10).each { |number| sorted_set.put(number, number) } }

  describe '#page' do
    it { expect(paginator.per(1).page(1).map(&:to_i)).to eq([10]) }
    it { expect(paginator.per(1).page(2).map(&:to_i)).to eq([9]) }
    it { expect(paginator.per(1).page(10).map(&:to_i)).to eq([1]) }
  end

  describe '#per' do
    it { expect(paginator.per(2).page(1).map(&:to_i)).to eq([10, 9]) }
    it { expect(paginator.per(3).page(1).map(&:to_i)).to eq([10, 9, 8]) }
    it { expect(paginator.per(4).page(1).map(&:to_i)).to eq([10, 9, 8, 7]) }
  end

  describe '#max_id' do
    it { expect(paginator.max_id(3).map(&:to_i)).to eq([2, 1]) }
    it { expect(paginator.max_id(4).map(&:to_i)).to eq([3, 2, 1]) }
  end

  describe '#since_id' do
    it { expect(paginator.since_id(8).map(&:to_i)).to eq([10, 9]) }
    it { expect(paginator.since_id(9).map(&:to_i)).to eq([10]) }
  end
end
