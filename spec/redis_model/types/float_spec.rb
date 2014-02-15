require 'spec_helper'

describe RedisModel::Types::Float do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:object) { klass.new }

  before { klass.data_type :float }

  describe '#to_f' do
      it { expect(object.to_f).to be_nil }

    context 'when value was set before' do
      let(:value) { 1.23 }

      before { object.set 1.23 }

      it { expect(object.to_f).to eq(1.23) }
    end
  end
end
