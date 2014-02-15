require 'spec_helper'

describe RedisModel::Types::Timestamp do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:object) { klass.new }

  before { klass.data_type :timestamp }

  describe '#to_time' do
    context 'when no value was set before' do
      it { expect(object.to_time).to be_nil }
    end

    context 'when value was set before' do
      let(:value) { DateTime.current }

      before { RedisModel::Base.connection.set(object.key_label, value) }

      it { expect(object.to_time.to_i).to eq(value.to_i) }
    end
  end
end
