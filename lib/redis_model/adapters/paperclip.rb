require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'paperclip'
require 'paperclip/glue'

module RedisModel
  module Adapters
    # Public: Adapter for putting Paperclip attachment into RedisModel::Base-
    # derived classes.
    module Paperclip
      extend ActiveSupport::Concern
      include RedisModel::Attribute

      included do
        extend ActiveModel::Callbacks
        include ActiveModel::Validations
        include ::Paperclip::Glue
        extend Override

        define_model_callbacks :save, :destroy, :commit
      end

      def save
        run_callbacks :save do
          true
        end
      end

      def destroy
        run_callbacks :destroy do
          true
        end
      end

      module Override
        def has_attached_file(*args)
          define_paperclip_attributes_for(args.first)

          super(*args)
        end

        def define_paperclip_attributes_for(attachment)
          redis_model_attribute :"#{attachment}_file_name", :string
          redis_model_attribute :"#{attachment}_file_size", :integer
          redis_model_attribute :"#{attachment}_content_type", :string
          redis_model_attribute :"#{attachment}_updated_at", :timestamp
        end
      end
    end
  end
end
