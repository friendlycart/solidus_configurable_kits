
//= require solidus_configurable_kits/templates/cart/kit_row

SolidusConfigurableKits = {
  Views: {
    Cart: {}
  }
}

SolidusConfigurableKits.Views.Cart.KitRow = Backbone.View.extend({
  tagName: 'tr',
  className: 'line-item',

  initialize: function (options) {
    var view = this;
    this.listenTo(this.model, "change", this.render);
    this.options = []
    var productId = view.model.get("kit_requirement").required_product_id
    Spree.ajax({
      type: 'GET',
      url: Spree.pathFor('api/products/' + productId),
      success: function(data) {
        if (data.variants.length) {
          view.options = data.variants.filter((v) => v.kit_price)
        } else {
          view.options = [data.master]
        }
        if (!view.model.get("variant")) {
          view.model.set("variant", view.options[0])
        }
        view.render()
      },
      error: function(msg) {
        if (msg.responseJSON["error"]) {
          show_flash('error', msg.responseJSON["error"]);
        } else {
          show_flash('error', "There was a problem loading kit variants.");
        }
      }
    });
  },

  events: {
    'click .edit-line-item': 'onEdit',
    'click .cancel-line-item': 'onCancel',
    'click .save-line-item': 'onSave',

    'change .js-kit-item-select': 'onSelectVariant',
  },

  onSelectVariant: function(event) {
    var selectedVariant = this.options.find((variant) => {
      return variant.id === parseInt(event.target.value)
    })
    this.model.set("variant", selectedVariant)
    this.render()
  },

  onEdit: function(e) {
    e.preventDefault()
    this.editing = true
    this.render()
  },

  onCancel: function(e) {
    e.preventDefault()
    this.editing = false
    this.render()
  },

  onSave: function(e) {
    e.preventDefault()

    var attrs = {
      variant_id: this.model.get('variant').id,
    }

    var model = this.model;
    this.model.save(attrs, {
      patch: true,
      success: function() {
        model.order.advance()
      }
    });
    this.editing = false;
    this.render();
  },

  render: function () {
    var optionsWithSelectedVariant = this.options.map((variant) => {

      variant.selected = variant.id === this.model.get("variant")?.id
      return variant
    })
    var html = HandlebarsTemplates['cart/kit_row']({
      line_item: this.model.toJSON(),
      editing: this.editing,
      showSelect: this.model.isNew() || this.editing,
      showButtons: !this.model.isNew(),
      options: optionsWithSelectedVariant
    });
    this.$el.html(html);
  }
});
