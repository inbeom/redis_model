require 'spec_helper'

describe RedisModel::Types::SortedSet do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:object) { klass.new }
  let(:members) { { one: 1, two: 2, three: 3 } }
  let(:populate) { members.each { |value, score| RedisModel::Base.connection.zadd object.key_label, score, value } }

  before { klass.data_type :sorted_set }

  describe '#to_a' do
    context 'when sorted set does not exist' do
      it { expect(object.to_a).to eq([]) }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it { expect(object.to_a.sort).to eq(members.keys.map(&:to_s).sort) }
    end
  end

  describe '#count_range' do
    context 'when sorted set does not exist' do
      it { expect(object.count_range(0, 4)).to eq(0) }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it { expect(object.count_range(0, 4)).to eq(members.length) }
    end
  end

  describe '#include?' do
    context 'when sorted set does not exist' do
      it { expect(object.include?(members.keys.first)).to be_false }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it { expect(object.include?(members.keys.first)).to be_true }
      it { expect(object.include?('unknown key')).to be_false }
    end
  end

  describe '#get_range_by_rank' do
    context 'when sorted set does not exist' do
      it { expect(object.get_range_by_rank(0, 1)).to eq([]) }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it { expect(object.get_range_by_rank(0, 0)).to eq(members.sort_by(&:last).reverse.slice(0, 1).map(&:first).map(&:to_s)) }
      it { expect(object.get_range_by_rank(0, 1)).to eq(members.sort_by(&:last).reverse.slice(0, 2).map(&:first).map(&:to_s)) }
      it { expect(object.get_range_by_rank(0, 2)).to eq(members.sort_by(&:last).reverse.slice(0, 3).map(&:first).map(&:to_s)) }
    end
  end

  describe '#get_range_by_reverse_rank' do
    context 'when sorted set does not exist' do
      it { expect(object.get_range_by_reverse_rank(0, 1)).to eq([]) }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it { expect(object.get_range_by_reverse_rank(0, 0)).to eq(members.sort_by(&:last).slice(0, 1).map(&:first).map(&:to_s)) }
      it { expect(object.get_range_by_reverse_rank(0, 1)).to eq(members.sort_by(&:last).slice(0, 2).map(&:first).map(&:to_s)) }
      it { expect(object.get_range_by_reverse_rank(0, 2)).to eq(members.sort_by(&:last).slice(0, 3).map(&:first).map(&:to_s)) }
    end
  end

  describe '#get_rank' do
    context 'when sorted set does not exist' do
      it { expect(object.get_rank(members.keys.first)).to be_nil }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it do
        members.each do |key, value|
          expect(object.get_rank(key)).to eq(members.sort_by(&:last).reverse.map(&:first).index(key))
        end
      end

      it { expect(object.get_rank('unknown')).to be_nil }
    end
  end

  describe '#score' do
    context 'when sorted set does not exist' do
      it { expect(object.score(members.keys.first)).to be_nil }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it do
        members.each do |key, value|
          expect(object.score(key)).to eq(members[key])
        end
      end

      it { expect(object.score('unknown')).to be_nil }
    end
  end

  describe '#count' do
    context 'when sorted set does not exist' do
      it { expect(object.count).to eq(0) }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it { expect(object.count).to eq(members.count) }
    end
  end

  describe '#get_range' do
    context 'when sorted set does not exist' do
      it { expect(object.get_range(0, 4)).to eq([]) }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it { expect(object.get_range(members.values.min, members.values.max)).to eq(members.reject { |k, v| [members.values.min, members.values.max].include?(v) }.keys.map(&:to_s)) }
      it { expect(object.get_range(members.values.min, members.values.max, include_boundaries: true)).to eq(members.sort_by(&:last).reverse.map(&:first).map(&:to_s)) }
    end
  end

  describe '#put' do
    it { expect { object.put(0, 'zero') }.to change { object.count }.by(1) }
  end

  describe '#remove' do
    context 'when sorted set does not exist' do
      it { expect { object.remove('one') }.not_to change { object.count } }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it { expect { object.remove(members.keys.first) }.to change { object.count } }
      it { expect { object.remove('unknown') }.not_to change { object.count } }
    end
  end

  describe '#remove_range' do
    context 'when sorted set does not exist' do
      it { expect { object.remove_range }.not_to change { object.count } }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it { expect { object.remove_range }.to change { object.count }.to(0) }
      it { expect { object.remove_range(members.values.min, members.values.max) }.to change { object.count }.to(0) }
      it { expect { object.remove_range(members.values.min + 1, members.values.max) }.to change { object.count }.to(1) }
    end
  end

  describe '#duplicate' do
    context 'when sorted set does not exist' do
      it { expect { object.duplicate('new') }.not_to change { RedisModel::Base.connection.keys } }
    end

    context 'when sorted set has been populated before' do
      before { populate }

      it { expect { object.duplicate('new') }.to change { RedisModel::Base.connection.keys } }
    end
  end

  describe '#intersect' do
    before { populate }

    context 'when operand is a sorted set' do
      let(:operand_klass) { dynamic_class(RedisModel::Base) }
      let(:operand) { operand_klass.new }
      let(:operand_members) { { three: 3, four: 4, five: 5 } }

      before { operand_klass.data_type :sorted_set }
      before { operand_members.each { |key, value| operand.put(value, key) } }

      context 'when block is not given' do
        it { expect(object.intersect(operand)).to be_kind_of(RedisModel::Intersected) }
        it { expect(object.intersect(operand).key_label).to be_include(object.key_label) }
        it { expect(object.intersect(operand).key_label).to be_include(operand.key_label) }

        context 'when seed is given' do
          let(:seed) { 123 }

          it { expect(object.intersect(operand, seed: seed).key_label).to be_include(seed.to_s) }
        end

        context 'when generated' do
          before { object.intersect(operand).generate }

          it { expect(object.intersect(operand)).to be_exists }
          it { expect(object.intersect(operand).to_a).to eq((members.keys & operand_members.keys).map(&:to_s)) }
        end
      end

      context 'when block is given' do
        it 'yields an instance of RedisModel::Intersected' do
          object.intersect(operand) do |intersected|
            expect(intersected).to be_kind_of(RedisModel::Intersected)
          end
        end

        it 'returns evaluation result of block' do
          expect(object.intersect(operand) do |intersected|
            intersected.to_a
          end).to eq((members.keys & operand_members.keys).map(&:to_s))
        end

        it 'the yielded instance has key_label which starts with caller\'s key_label' do
          object.intersect(operand) do |intersected|
            expect(intersected.key_label).to be_include(object.key_label)
            expect(intersected.key_label).to be_include(operand.key_label)
          end
        end

        it 'clears up intersected set' do
          key_label = nil

          object.intersect(operand) do |intersected|
            key_label = intersected.key_label
          end

          expect(RedisModel::Base.connection.exists(key_label)).to be_false
        end

        context 'when seed is given' do
          let(:seed) { 123 }

          it 'adds seed string to key_label' do
            key_label = nil

            object.intersect(operand, seed: seed) do |intersected|
              key_label = intersected.key_label
            end

            expect(key_label).to be_include(seed.to_s)
          end
        end
      end
    end

    context 'when operand is a set' do
      let(:operand_klass) { dynamic_class(RedisModel::Base) }
      let(:operand) { operand_klass.new }
      let(:operand_members) { [:three, :four, :five] }

      before { operand_klass.data_type :set }
      before { operand_members.each { |value| operand << value } }

      context 'when block is not given' do
        it { expect(object.intersect(operand)).to be_kind_of(RedisModel::Intersected) }
        it { expect(object.intersect(operand).key_label).to be_include(object.key_label) }
        it { expect(object.intersect(operand).key_label).to be_include(operand.key_label) }

        context 'when generated' do
          before { object.intersect(operand).generate }

          it { expect(object.intersect(operand)).to be_exists }
          it { expect(object.intersect(operand).to_a).to eq((members.keys & operand_members).map(&:to_s)) }
        end
      end

      context 'when block is given' do
        it 'yields an instance of RedisModel::Intersected' do
          object.intersect(operand) do |intersected|
            expect(intersected).to be_kind_of(RedisModel::Intersected)
          end
        end

        it 'the yielded instance has key_label which starts with caller\'s key_label' do
          object.intersect(operand) do |intersected|
            expect(intersected.key_label).to be_include(object.key_label)
            expect(intersected.key_label).to be_include(operand.key_label)
          end
        end

        it 'clears up intersected set' do
          key_label = nil

          object.intersect(operand) do |intersected|
            key_label = intersected.key_label
          end

          expect(RedisModel::Base.connection.exists(key_label)).to be_false
        end
      end
    end
  end
end
