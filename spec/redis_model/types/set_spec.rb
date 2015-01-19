require 'spec_helper'

describe RedisModel::Types::Set do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:object) { klass.new }

  before { klass.data_type :set }

  describe '#to_a' do
    context 'when set does not exist' do
      it { expect(object.to_a).to eq([]) }
    end

    context 'when set has been populated before' do
      let(:elements) { ['testelement1', 'testelement2'] }

      before { elements.each { |element| RedisModel::Base.connection.sadd(object.key_label, element) } }

      it { expect(object.to_a.sort).to eq(elements.sort) }
    end
  end

  describe '#count' do
    context 'when set does not exist' do
      it { expect(object.count).to eq(0) }
    end

    context 'when set has been populated before' do
      let(:elements) { ['testelement1', 'testelement2'] }

      before { elements.each { |element| RedisModel::Base.connection.sadd(object.key_label, element) } }

      it { expect(object.count).to eq(elements.count) }
    end
  end

  describe '#<<' do
    it { expect { object << 1 }.to change { object.count }.by(1) }
  end

  describe '#remove' do
    let(:elements) { ['testelement1', 'testelement2'] }

    before { elements.each { |element| RedisModel::Base.connection.sadd(object.key_label, element) } }

    context 'when removing existing element' do
      it { expect { object.remove(elements.first) }.to change { object.count }.by(-1) }
    end

    context 'when removing non-existent element' do
      it { expect { object.remove('nonexistent') }.not_to change { object.count } }
    end
  end

  describe '#pick' do
    let(:elements) { ['testelement1', 'testelement2'] }

    before { elements.each { |element| RedisModel::Base.connection.sadd(object.key_label, element) } }

    it { expect(object.pick(5).all? { |e| elements.include?(e) }).to eq(true) }
  end
end
