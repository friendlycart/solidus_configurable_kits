# frozen_string_literal: true

module SolidusConfigurableKits
  module Spree
    module Api
      module LineItemsControllerDecorator

        def create
          variant = ::Spree::Variant.find(params[:line_item][:variant_id])
          @line_item = @order.contents.add(
            variant,
            params[:line_item][:quantity] || 1,
            line_item_params.to_h.slice(:kit_variant_ids)
          )

          if @line_item.errors.empty?
            respond_with(@line_item, status: 201, default_template: :show)
          else
            invalid_resource!(@line_item)
          end
        end

        def update
          @line_item = @order.line_items.find(params[:id])
          if @line_item.update(line_item_params)
            @order.line_items.reload
            @order.ensure_updated_shipments
            @order.recalculate
            respond_with(@line_item, default_template: :show)
          else
            invalid_resource!(@line_item)
          end
        end

        ::Spree::Api::LineItemsController.prepend self
      end
    end
  end
end
