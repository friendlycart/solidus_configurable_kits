
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
    var productId = view.model.get("product_id") || view.model.get("variant").product_id
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
    'change .js-kit-item-select': 'onSelectVariant',
  },

  onSelectVariant: function(event) {
    var selectedVariant = this.options.find((variant) => {
      return variant.id === parseInt(event.target.value)
    })
    this.model.set("variant", selectedVariant)
    this.render()
  },

  render: function () {
    console.log(this.model.get("variant"))
    var optionsWithSelectedVariant = this.options.map((variant) => {

      variant.selected = variant.id === this.model.get("variant")?.id
      return variant
    })
    var html = HandlebarsTemplates['cart/kit_row']({
      line_item: this.model.toJSON(),
      isNew: this.model.isNew(),
      options: optionsWithSelectedVariant
    });
    this.$el.html(html);
  }
});
