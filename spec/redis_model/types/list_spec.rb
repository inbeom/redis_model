require 'spec_helper'

describe RedisModel::Types::List do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:object) { klass.new }

  before { klass.data_type :list }

  describe '#to_a' do
    context 'when list does not exist' do
      it { expect(object.to_a).to eq([]) }
    end

    context 'when list has been populated before' do
      let(:elements) { ['testelement1', 'testelement2'] }

      before { elements.each { |element| RedisModel::Base.connection.rpush(object.key_label, element) } }

      it { expect(object.to_a).to eq(elements) }
    end
  end

  describe '#count' do
    context 'when list does not exist' do
      it { expect(object.count).to eq(0) }
    end

    context 'when list has been populated before' do
      let(:elements) { ['testelement1', 'testelement2'] }

      before { elements.each { |element| RedisModel::Base.connection.rpush object.key_label, element } }

      it { expect(object.count).to eq(elements.length) }
    end
  end

  describe '#[]' do
    context 'when list does not exist' do
      it { expect(object[1]).to be_nil }
    end

    context 'when list has been populated before' do
      let(:elements) { ['testelement1', 'testelement2'] }

      before { elements.each { |element| RedisModel::Base.connection.rpush object.key_label, element } }

      it { expect(object[0]).to eq(elements[0]) }
      it { expect(object[1]).to eq(elements[1]) }
    end
  end

  describe '#<<' do
    it { expect { object << 1 }.to change { object.count }.by(1) }
  end
end
