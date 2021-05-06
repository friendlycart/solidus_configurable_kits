# frozen_string_literal: true

module SolidusConfigurableKits
  module Admin
    class KitRequirementsController < ::Spree::Admin::ResourceController
      belongs_to 'spree/product', find_by: :slug

      def index; end

      private

      def model_class
        SolidusConfigurableKits::Requirement
      end

      def new_object_url
        solidus_configurable_kits.new_admin_product_kit_requirement_url(@product.slug)
      end

      def edit_object_url(object)
        solidus_configurable_kits.edit_admin_product_kit_requirement_url(id: object, product_id: @product.slug)
      end

      def object_url(object)
        solidus_configurable_kits.admin_product_kit_requirement_url(id: object, product_id: @product.slug)
      end

      def collection_url
        solidus_configurable_kits.admin_product_kit_requirements_url(@product)
      end
    end
  end
end
