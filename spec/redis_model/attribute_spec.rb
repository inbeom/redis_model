require 'spec_helper'

class TestModel
  attr_accessor :id, :custom

  def initialize(id, custom = nil)
    @id = id
    @custom = custom
  end
end

class TestActiveRecordModel < ActiveRecord::Base
  self.table_name = 'ar_model'
end

describe RedisModel::Attribute do
  let(:parent_klass) { dynamic_class(TestModel) }

  before { parent_klass.send(:include, RedisModel::Attribute) }

  describe '.redis_model_attribute' do
    let(:attribute_name) { :my_counter }
    let(:attribute_type) { :counter }
    let(:test_id) { 'test' }

    it { expect { parent_klass.redis_model_attribute attribute_name, attribute_type }.to change { parent_klass.new(test_id).respond_to?(attribute_name) } }
    it { expect { parent_klass.redis_model_attribute attribute_name, attribute_type }.to change { parent_klass.new(test_id).respond_to?(:"#{attribute_name}=") } }

    context 'when belonged_to klass is defined' do
      let(:key_label) { parent_klass.new(test_id).send(attribute_name).key_label }

      before { parent_klass.redis_model_attribute attribute_name, attribute_type }

      it { expect(parent_klass.new(test_id).send(attribute_name)).to be_kind_of(RedisModel::BelongedTo) }
      it { expect(parent_klass.new(test_id).send(attribute_name).class.included_modules).to include(RedisModel::Types::Counter) }
      it { expect(key_label).to end_with(test_id) }
      it { expect(key_label).to include(parent_klass.to_s.underscore) }
    end

    context 'when parent klass is inherited' do
      let(:child_klass) { dynamic_class(parent_klass) }

      it { expect { parent_klass.redis_model_attribute attribute_name, attribute_type }.to change { child_klass.new(test_id).respond_to?(attribute_name) } }
      it { expect { parent_klass.redis_model_attribute attribute_name, attribute_type }.to change { child_klass.new(test_id).respond_to?(:"#{attribute_name}=") } }

      context 'when belonged_to klass is defined' do
        before { parent_klass.redis_model_attribute attribute_name, attribute_type }

        it { expect(parent_klass.new(test_id).send(attribute_name).class).to eq(child_klass.new(test_id).send(attribute_name).class) }
        it { expect(parent_klass.new(test_id).send(attribute_name).key_label).to eq(child_klass.new(test_id).send(attribute_name).key_label) }
      end
    end

    context 'when foreign_key option is specified' do
      let(:custom_id) { 'customid' }
      let(:key_label) { parent_klass.new(test_id, custom_id).send(attribute_name).key_label }

      before { parent_klass.redis_model_attribute attribute_name, attribute_type, foreign_key: :custom }

      it { expect(key_label).to end_with(custom_id) }
      it { expect(key_label).to include(parent_klass.to_s.underscore) }
      it { expect(key_label).to end_with(custom_id) }
      it { expect(key_label).not_to end_with(test_id) }
    end

    describe '.redis_model_attributes' do
      it { expect(parent_klass.redis_model_attributes).to be_kind_of(RedisModel::Attribute::DefinitionHelper) }
      it { expect { parent_klass.redis_model_attributes { counter :my_counter } }.to change { parent_klass.new(test_id).methods } }
    end
  end

  describe RedisModel::Attribute::DefinitionHelper do
    let(:parent_klass) { dynamic_class(TestModel) }
    let(:definition_helper) { RedisModel::Attribute::DefinitionHelper.new parent_klass, {} }

    it { expect(definition_helper).to respond_to(:counter) }
    it { expect(definition_helper).to respond_to(:set) }
    it { expect(definition_helper).to respond_to(:sorted_set) }
    it { expect { definition_helper.counter :my_counter }.to change { parent_klass.new('test').methods } }
  end

  describe '#clear_redis_modeL_attributes' do
    let(:parent_klass) { dynamic_class(TestModel) }
    let(:attribute_name) { :my_counter }
    let(:attribute_type) { :counter }
    let(:test_id) { 'test' }
    let(:object) { parent_klass.new(test_id) }
    let(:redis_model_attribute) { object.send(attribute_name) }

    context 'when current class defines the attribute' do
      before { parent_klass.redis_model_attribute attribute_name, attribute_type }
      before { redis_model_attribute.set(1) }

      it { expect { object.clear_redis_model_attributes }.to change { RedisModel::Base.connection.get(redis_model_attribute.key_label) }.to(nil) }
    end

    context 'when parent class defines the attribute' do
      let(:current_klass) { dynamic_class(parent_klass) }
      let(:object) { current_klass.new(test_id) }

      before { parent_klass.redis_model_attribute attribute_name, attribute_type }
      before { redis_model_attribute.set(1) }

      it { expect { object.clear_redis_model_attributes }.to change { RedisModel::Base.connection.get(redis_model_attribute.key_label) }.to(nil) }
    end

    context 'when parent class is activerecord model' do
      let(:parent_klass) { dynamic_class(TestActiveRecordModel) }
      let(:object) { parent_klass.create }

      before { parent_klass.redis_model_attribute attribute_name, attribute_type }
      before { redis_model_attribute.set(1) }

      context 'when it is cleared explicitly' do
        it { expect { object.clear_redis_model_attributes }.to change { RedisModel::Base.connection.get(redis_model_attribute.key_label) }.to(nil) }
      end

      context 'when it is invoked via activerecord callback' do
        it { expect { object.destroy }.to change { RedisModel::Base.connection.get(redis_model_attribute.key_label) }.to(nil) }
      end
    end
  end
end
