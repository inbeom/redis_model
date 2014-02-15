require 'spec_helper'

describe RedisModel::Types::Hash do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:object) { klass.new }

  before { klass.data_type :hash }

  describe '#[]=' do
    let(:key) { :some_key }
    let(:value) { 'hello world' }

    it { expect(object.[]=(key, value)).to eq(value) }
  end

  describe '#[]' do
    let(:key) { :some_key }

    context 'when value was not set before' do
      it { expect(object[key]).to be_nil }
    end

    context 'when value was set before' do
      let(:value) { 'hello world' }

      before { object[key] = value }

      it { expect(object[key]).to eq(value) }
    end
  end

  describe '#incr' do
    let(:key) { :some_key }

    context 'when key does not exist before' do
      it { expect(object.incr(key)).to eq(1) }
      it { expect { object.incr(key) }.to change { object[key] }.from(nil).to(1.to_s) }
    end

    context 'when amount is given' do
      let(:by) { 3 }

      it { expect(object.incr(key, by)).to eq(by) }
      it { expect { object.incr(key, by) }.to change { object[key] }.from(nil).to(by.to_s) }
    end

    context 'when key was set before' do
      let(:initial) { 2 }

      before { object[key] = initial }

      it { expect { object.incr(key) }.to change { object[key] }.from(initial.to_s).to((initial + 1).to_s) }
    end
  end
end
