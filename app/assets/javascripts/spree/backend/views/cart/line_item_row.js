Spree.Views.Cart.LineItemRow = Backbone.View.extend({
  tagName: 'tr',
  className: 'line-item',

  initialize: function(options) {
    this.listenTo(this.model, "remove", this.onSetVariant);
    this.listenTo(this.model, "change:variant", this.onSetVariant);
    this.listenTo(this.model, "change", this.render);
    this.editing = options.editing || this.model.isNew();
  },

  events: {
    'click .edit-line-item': 'onEdit',
    'click .cancel-line-item': 'onCancel',
    'click .save-line-item': 'onSave',
    'submit form': 'onSave',
    'click .delete-line-item': 'onDelete',
    'change .js-select-variant': 'onSelectVariant',
  },

  onEdit: function(e) {
    e.preventDefault()
    this.editing = true
    this.render()
  },

  onCancel: function(e) {
    e.preventDefault();
    if (this.model.isNew()) {
      this.model.unset("variant")
      this.remove()
      this.model.destroy()
    } else {
      this.editing = false;
      this.render();
    }
  },

  onSelectVariant: function (event) {
    this.model.set('variant', event.added)
  },

  onSetVariant: function () {
    var variant = this.model.get("variant")

    // Remove any requirements from a previous kit line item
    this.model.collection.remove(
      this.model.collection.models.filter((el) => el.attributes.kit === this.model)
    )
    // Add the requirements for this line item
    if (variant && variant.kit_requirements) {
      variant.kit_requirements.map((kit_requirement) =>
        Array.from({ length: kit_requirement.quantity }).map(() => {
          return {
            kit: this.model,
            productId: kit_requirement.required_product_id,
            quantity: 1,
            kitRequirementName: kit_requirement.name
          }
        })
      ).flat().forEach((element) =>
        this.model.collection.push(element)
      )
    }
  },

  validate: function () {
    this.$('[name=quantity]').toggleClass('error', !this.$('[name=quantity]').val());
    this.$('.select2-container').toggleClass('error', !this.$('[name=variant_id]').val());

    return !this.$('.select2-container').hasClass('error') && !this.$('[name=quantity]').hasClass('error')
  },

  onSave: function(e) {
    e.preventDefault()
    if(!this.validate()) {
      return;
    }
    var attrs = {
      quantity: parseInt(this.$('input.line_item_quantity').val()),
      variant_id: this.model.get('variant').id
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

  onDelete: function(e) {
    e.preventDefault()
    if(!confirm(Spree.translations.are_you_sure_delete)) {
      return;
    }
    this.remove()
    var model = this.model;
    this.model.destroy({
      success: function() {
        model.order.advance()
      }
    })
  },

  render: function() {
    var html = HandlebarsTemplates['orders/line_item']({
      line_item: this.model.toJSON(),
      editing: this.editing,
      isNew: this.model.isNew() && !this.model.get('variant'),
    });
    this.$el.html(html);
    this.$("[name=variant_id]").variantAutocomplete({ suppliable_only: true });
  }
});
