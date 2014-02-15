require 'spec_helper'

describe RedisModel::Types::String do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:object) { klass.new }

  before { klass.data_type :string }

  describe '#get' do
    context 'when no value was set before' do
      it { expect(object.get).to be_nil }
    end

    context 'when value was set before' do
      let(:value) { 'hi' }

      before { RedisModel::Base.connection.set(object.key_label, value) }

      it { expect(object.get).to eq(value) }
    end
  end

  describe '#set' do
    context 'when value was set before' do
      it { expect { object.set('value') }.to change { RedisModel::Base.connection.get object.key_label } }
    end
  end
end
