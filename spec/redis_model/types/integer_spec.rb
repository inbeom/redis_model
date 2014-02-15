require 'spec_helper'

describe RedisModel::Types::Integer do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:object) { klass.new }

  before { klass.data_type :integer }

  describe '#to_i' do
    context 'when no value was set before' do
      it { expect(object.to_i).to be_nil }
    end

    context 'when value was set before' do
      let(:value) { 2 }

      before { RedisModel::Base.connection.set(object.key_label, value) }

      it { expect(object.to_i).to eq(value) }
    end
  end
end
