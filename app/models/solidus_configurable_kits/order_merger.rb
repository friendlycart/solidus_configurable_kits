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
        other_order.line_items.reject(&:kit_item?).each do |other_order_line_item|
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

    # Merge the `other_order_line_item` into `current_line_item`
    #
    # If `current_line_item` is nil, the `other_order_line_item` will be
    # re-assigned to the `order`.
    #
    # If the merged line item can not be saved, an error will be added to
    # `order`.
    #
    # @api privat
    # @param [Spree::LineItem] current_line_item The line item to be merged
    # into. If nil, the `other_order_line_item` will be re-assigned.
    # @param [Spree::LineItem] other_order_line_item The line item to merge in.
    # @return [void]
    def handle_merge(current_line_item, other_order_line_item)
      if current_line_item
        current_line_item.quantity += other_order_line_item.quantity
        handle_error(current_line_item) unless current_line_item.save
      else
        new_line_item = order.line_items.build(other_order_line_item.attributes.except("id"))
        other_order_line_item.kit_items.each do |kit_item|
          new_line_item.kit_items.build(
            kit_item.attributes.except("id").merge(order: order)
          )
        end
        handle_error(new_line_item) unless new_line_item.save
      end
    end
  end
end
