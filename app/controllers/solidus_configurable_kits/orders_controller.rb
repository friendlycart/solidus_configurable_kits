# frozen_string_literal: true

module SolidusConfigurableKits
  class OrdersController < ::Spree::StoreController
    helper "spree/products", "spree/orders"

    respond_to :html

    before_action :store_guest_token

    # Adds a new Kit to the order (creating a new order if none already exists)
    # Mostly mirrors to Spree::OrdersController#populate action!
    def populate_kit
      @order = current_order(create_order_if_necessary: true)
      authorize! :update, @order, cookies.signed[:guest_token]

      variant = ::Spree::Variant.find(params[:variant_id])
      quantity = params[:quantity].present? ? params[:quantity].to_i : 1
      options = {kit_variant_ids: params[:kit_variant_ids]}

      # 2,147,483,647 is crazy. See issue https://github.com/spree/spree/issues/2695.
      if !quantity.between?(1, 2_147_483_647)
        @order.errors.add(:base, t("spree.please_enter_reasonable_quantity"))
      else
        begin
          @line_item = @order.contents.add(variant, quantity, options)
          @order.line_items.reload
          @order.recalculate
        rescue ActiveRecord::RecordInvalid => e
          @order.errors.add(:base, e.record.errors.full_messages.join(", "))
        end
      end

      respond_with(@order) do |format|
        format.html do
          if @order.errors.any?
            flash[:error] = @order.errors.full_messages.join(", ")
            redirect_back_or_default(spree.root_path)
            return
          else
            redirect_to spree.cart_path
          end
        end
      end
    end

    private

    def store_guest_token
      cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
    end
  end
end
