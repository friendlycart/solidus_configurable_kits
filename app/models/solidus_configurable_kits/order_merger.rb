# frozen_string_literal: true

module SolidusConfigurableKits
  class OrderMerger < ::Spree::OrderMerger
    # Merge a second order in to the order the OrderMerger was initialized with
    #
    # The line items from `other_order` will be merged in to the `order` for
    # this OrderMerger object. If the line items are for the same variant, it
    # will add the quantity of the incoming line item to the existing line item.
    # Otherwise, it will assign the line item to the new order.
    #
    # After the orders have been merged the `other_order` will be destroyed.
    #
    # @example
    #   initial_order = Spree::Order.find(1)
    #   order_to_merge = Spree::Order.find(2)
    #   merger = Spree::OrderMerger.new(initial_order)
    #   merger.merge!(order_to_merge)
    #   # order_to_merge is destroyed, initial order now contains the line items
    #   # of order_to_merge
    #
    # @api public
    # @param [Spree::Order] other_order An order which will be merged in to the
    # order the OrderMerger was initialized with.
    # @param [Spree::User] user Associate the order the user specified. If not
    # specified, the order user association will not be changed.
    # @return [void]
    def merge!(other_order, user = nil)
      if other_order.currency == order.currency
        other_order.line_items.each do |other_order_line_item|
          current_line_item = find_matching_line_item(other_order_line_item)
          handle_merge(current_line_item, other_order_line_item)
        end
      end

      set_user(user)
      if order.valid?
        persist_merge

        # So that the destroy doesn't take out line items which may have been re-assigned
        other_order.line_items.reload
        other_order.destroy
      end
    end
  end
end
