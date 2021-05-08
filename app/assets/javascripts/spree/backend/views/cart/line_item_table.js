//= require solidus_configurable_kits/views/cart/kit_row

Spree.Views.Cart.LineItemTable = Backbone.View.extend({
  initialize: function() {
    this.listenTo(this.collection, 'add', this.add);
    this.listenTo(this.collection, 'reset', this.reset);
    this.listenTo(this.collection, 'remove', this.reset);
  },

  add: function(model) {
    var view;
    if (model.get('kit')) {
      view = new SolidusConfigurableKits.Views.Cart.KitRow({ model: model });
    } else {
      view = new Spree.Views.Cart.LineItemRow({ model: model });
    }
    view.render();
    this.$el.append(view.el);
  },

  reset: function(event) {
    this.$el.empty();
    this.collection.models.forEach((line_item) => {
      this.add(line_item)
    })
  },
});
