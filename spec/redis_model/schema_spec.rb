require 'spec_helper'
require 'redis_model/schema'

describe RedisModel::Schema do
  let(:random_string) { SecureRandom.base64(4).tr('+/=lIO0', 'pqrsxyz') }

  describe '.collection' do
    it { expect(RedisModel::Schema.collection).to be_kind_of(Hash) }
  end

  describe '.find' do
    let(:parent_klass) { Class.new }
    let(:child_klass) { Class.new parent_klass }

    before { RedisModel::Schema.collection.clear }

    context 'when there is no entry of direct ancestor' do
      it { expect(RedisModel::Schema.find(parent_klass)).to be_nil }
      it { expect(RedisModel::Schema.find(child_klass)).to be_nil }
    end

    context 'when collection is populated' do
      let(:value) { 1234 }

      before { RedisModel::Schema.collection[child_klass] = value }

      it { expect(RedisModel::Schema.find(child_klass)).to eq(value) }
      it { expect(RedisModel::Schema.find(parent_klass)).to be_nil }
    end

    context 'when collection is populated by both' do
      let(:parent_value) { 1234 }
      let(:child_value) { 4321 }

      before { RedisModel::Schema.collection[parent_klass] = parent_value }
      before { RedisModel::Schema.collection[child_klass] = child_value }

      it { expect(RedisModel::Schema.find(parent_klass)).to eq(parent_value) }
      it { expect(RedisModel::Schema.find(child_klass)).to eq(child_value) }
    end
  end

  describe '.register' do
    let(:parent_klass) { Class.new.tap { |k| Object.const_set("Parent#{random_string}", k) } }
    let(:child_klass) { Class.new parent_klass.tap { |k| Object.const_set("Child#{random_string}", k) } }

    before { RedisModel::Schema.collection.clear }

    context 'when data_type is invalid' do
      it { expect { RedisModel::Schema.register(parent_klass, data_type: :nothing) }.to raise_error(RedisModel::Schema::UnknownType) }
    end

    context 'when data_type is valid' do
      it { expect { RedisModel::Schema.register(parent_klass, data_type: :string) }.not_to raise_error }
      it { expect(RedisModel::Schema.register(parent_klass, data_type: :string)).to eq(RedisModel::Types::String) }
    end
  end

  describe '#initialize' do
    context 'when invalid data_type key is given' do
      it { expect { RedisModel::Schema.new(data_type: :something_i_dont_know) }.to raise_error(RedisModel::Schema::UnknownType) }
    end

    context 'when valid data_type key is given' do
      let(:klass) { Class.new.tap { |k| Object.const_set("Parent#{random_string}", k) } }
      let(:data_type) { :string }
      let(:schema) { RedisModel::Schema.new(data_type: data_type, klass: klass) }

      it { expect { schema }.not_to raise_error }
      it { expect(schema.klass).to eq(klass) }
      it { expect(schema.data_type).to eq(data_type) }
    end
  end

  describe '#custom_key_label' do
    let(:string_child_klass) { Class.new(String).tap { |k| Object.const_set("String#{random_string}", k) } }
    let(:schema) { RedisModel::Schema.new data_type: :string, klass: string_child_klass }
    let(:object) { string_child_klass.new('test') }

    context 'when block is given' do
      it { expect { schema.custom_key_label { |o| o.reverse } }.not_to raise_error }
      it { expect { schema.custom_key_label { |o| o.reverse } }.to change { schema.key_label(object).end_with?(':tset') } }
    end

    context 'when method is given' do
      it { expect { schema.custom_key_label(&:reverse) }.not_to raise_error }
      it { expect { schema.custom_key_label(&:reverse) }.to change { schema.key_label(object).end_with?(':tset') } }
    end
  end

  describe '#key_label' do
    let(:klass) { Class.new.tap { |k| Object.const_set("Klass#{random_string}", k) } }
    let(:schema) { RedisModel::Schema.new klass: klass, data_type: :string }
    let(:object) { klass.new }
    let(:app_name) { nil }

    before { RedisModel::Configurations.instance.app_name = app_name }

    context 'when no custom key labels and app name present' do
      it { expect(schema.key_label(object)).to include(klass.name.underscore) }
    end

    context 'when custom key label presents' do
      let(:label_text) { 'test' }
      before { schema.custom_key_label { |o| label_text } }

      it { expect(schema.key_label(object)).to include(klass.name.underscore) }
      it { expect(schema.key_label(object)).to include(label_text) }
    end

    context 'when app name presents' do
      let(:app_name) { 'app' }

      it { expect(schema.key_label(object)).to include(klass.name.underscore) }
      it { expect(schema.key_label(object)).to include(app_name) }
    end
  end
end
