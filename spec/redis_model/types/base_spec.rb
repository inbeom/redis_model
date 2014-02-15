require 'spec_helper'

describe RedisModel::Types::Base do
  let(:klass) { dynamic_class(RedisModel::Base) }
  let(:object) { klass.new }

  before { RedisModel::Schema.register(klass, data_type: :string) }
  before { klass.send(:include, RedisModel::Types::Base) }

  describe '#exists?' do
    it { expect(object.exists?).to be_false }
    it { expect { RedisModel::Base.connection.set(object.key_label, 'value') }.to change { object.exists? } }
  end

  describe '#del' do
    context 'when object exists' do
      before { RedisModel::Base.connection.set(object.key_label, 'value') }

      it { expect { object.del }.to change { object.exists? } }
      it { expect(object.del).to eq(1) }
    end

    context 'when object does not exist' do
      it { expect { object.del }.not_to change { object.exists? } }
      it { expect(object.del).to eq(0) }
    end
  end
end
