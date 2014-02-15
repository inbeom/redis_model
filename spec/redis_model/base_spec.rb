require 'spec_helper'

describe RedisModel::Base do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:another_klass) { dynamic_class(RedisModel::Base, 'Another') }

  describe '.data_type' do
    it { expect { klass.data_type(:value) }.to change { RedisModel::Schema.collection.keys }.by([klass]) }
    it { expect { klass.data_type(:string) }.to change { RedisModel::Schema.collection[klass] }.from(nil) }
    it { expect { klass.data_type(:string) }.to change { klass.included_modules.include?(RedisModel::Types::String) }.from(false).to(true) }

    context 'when child class tries to redefine data type' do
      let(:child_klass) { dynamic_class(klass, 'Child') }

      before { klass.data_type(:value) }

      it { expect { child_klass.data_type(:value) }.to raise_error(RedisModel::Schema::DuplicateDefinition) }
    end

    context 'when another class defines its data type' do
      before { klass.data_type(:value) }

      it { expect { another_klass.data_type(:string) }.not_to change { RedisModel::Schema.find(klass) } }
    end
  end

  describe '.connection' do
    before { klass.data_type :counter }
    before { another_klass.data_type :string }

    it { expect(klass.connection).to be_kind_of(Redis) }
    it { expect(klass.connection).to eq(another_klass.connection) }
  end
end
