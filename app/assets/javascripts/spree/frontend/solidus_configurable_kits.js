// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js'
Spree.ready(function($) {
  Spree.updateKitPrice = function() {
    var variantPrice = $("input[name='variant_id']:checked")[0].dataset.price;
    var selectedKitItemPrices = Array.prototype.slice.call(
      $("select.kit_variant_input")
      ).map((element) => {
      return element.options[element.selectedIndex].dataset.price;
    })
    var unselectableKitItemPrices = Array.prototype.slice.call(
      $("input.kit_variant_input")
      ).map((element) => {
      return element.dataset.price;
    })

    var sum = [variantPrice].
      concat(selectedKitItemPrices).
      concat(unselectableKitItemPrices).
      map((p) => p.replace(/[$,]+/g, "")).
      map(Number).
      filter((price) => !isNaN(price)).
      reduce((a, b) => a + b, 0)
    if (variantPrice) {
      var formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'EUR',
      });

      $(".price.selling").text(formatter.format(sum));
    }
  };

  $("select.kit_variant_input, input[name='variant_id'").change(function(event) {
    Spree.updateKitPrice();
  });
});
