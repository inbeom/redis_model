require 'spec_helper'

describe RedisModel::Types::Counter do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:object) { klass.new }

  before { klass.data_type :counter }

  describe '#incr' do
    it { expect { object.incr }.to change { object.to_i }.from(0).to(1) }
    it { expect(object.incr).to eq(1) }

    context 'when argument is given' do
      let(:by) { 3 }

      it { expect { object.incr(by) }.to change { object.to_i }.from(0).to(by) }
      it { expect(object.incr(by)).to eq(by) }
    end
  end

  describe '#to_i' do
    it { expect(object.to_i).to eq(0) }

    context 'when value was set previously' do
      let(:value) { 3 }

      before { RedisModel::Base.connection.set(object.key_label, value) }

      it { expect(object.to_i).to eq(value) }
    end
  end
end
