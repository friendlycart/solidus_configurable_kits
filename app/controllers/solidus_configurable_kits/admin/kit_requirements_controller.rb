# frozen_string_literal: true

module SolidusConfigurableKits
  module Admin
    class KitRequirementsController < ::Spree::Admin::ResourceController
      belongs_to 'spree/product', find_by: :slug

      def index
      end

      private

      def model_class
        SolidusConfigurableKits::Requirement
      end
    end
  end
end
