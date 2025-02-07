# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusConfigurableKits::PriceSelector do
  subject { described_class.new(variant) }

  let(:variant) { build_stubbed(:variant) }

  it { is_expected.to respond_to(:variant) }
  it { is_expected.to respond_to(:price_for) }
  it { is_expected.to respond_to(:price_for_options) }

  describe ".pricing_options_class" do
    it "returns the standard pricing options class" do
      expect(described_class.pricing_options_class).to eq(SolidusConfigurableKits::PricingOptions)
    end
  end

  describe "#price_for(options)" do
    let(:variant) { create(:variant, price: 12.34) }
    let(:pricing_options) { described_class.pricing_options_class.new(currency: "USD") }

    it "returns the correct (default) price as a Spree::Money object", :aggregate_failures do
      expect(Spree::Deprecation).to receive(:warn).
        with(/^price_for is deprecated and will be removed/, any_args)
      expect(subject.price_for(pricing_options)).to eq(Spree::Money.new(12.34, currency: "USD"))
    end
  end

  describe "#price_for_options(options)" do
    let(:variant) { create(:variant, price: 12.34) }

    context "with the default currency" do
      let(:pricing_options) { described_class.pricing_options_class.new(currency: "USD") }

      it "returns the price as a Spree::Price object" do
        expect(subject.price_for_options(pricing_options)).to be_a Spree::Price
      end

      it "returns the correct (default) price", :aggregate_failures do
        expect(subject.price_for_options(pricing_options).amount).to eq 12.34
        expect(subject.price_for_options(pricing_options).currency).to eq "USD"
      end

      context "with the another country iso" do
        let(:country) { create(:country, iso: "DE") }

        let(:pricing_options) do
          described_class.pricing_options_class.new(currency: "USD", country_iso: "DE")
        end

        context "with a price for that country present" do
          before do
            variant.prices.create(amount: 44.44, country: country, currency: Spree::Config.currency)
          end

          it "returns the correct price and currency", :aggregate_failures do
            expect(subject.price_for_options(pricing_options).amount).to eq 44.44
            expect(subject.price_for_options(pricing_options).currency).to eq "USD"
          end
        end

        context "with no price for that country present" do
          context "and no fallback price for the variant present" do
            before do
              variant.prices.delete_all
            end

            it "returns nil" do
              expect(subject.price_for_options(pricing_options)).to be_nil
            end
          end

          context "and a fallback price for the variant present" do
            before do
              variant.prices.create(amount: 55.44, country: nil, currency: Spree::Config.currency)
            end

            it "returns the fallback price" do
              expect(subject.price_for_options(pricing_options).amount).to eq 55.44
            end
          end
        end
      end
    end

    context "with a different currency" do
      let(:pricing_options) { described_class.pricing_options_class.new(currency: "EUR") }

      context "when there is a price for that currency" do
        before do
          variant.prices.create(amount: 99.00, currency: "EUR")
        end

        it "returns the price in the correct currency", :aggregate_failures do
          expect(subject.price_for_options(pricing_options).amount).to eq 99.00
          expect(subject.price_for_options(pricing_options).currency).to eq "EUR"
        end
      end

      context "when there is no price for that currency" do
        it "returns nil" do
          expect(subject.price_for_options(pricing_options)).to be_nil
        end
      end
    end

    context "with a kit item price but normal price requested" do
      let(:normal_price) { create(:price, amount: 12, kit_item: false) }
      let(:kit_price) { create(:price, amount: 2, kit_item: true) }
      let(:variant) { create(:variant, prices: [normal_price, kit_price]) }
      let(:pricing_options) { described_class.pricing_options_class.new(kit_item: false) }

      it "returns the normal price" do
        expect(subject.price_for_options(pricing_options).amount).to eq 12.00
      end

      context "with a kit item price requested" do
        let(:pricing_options) { described_class.pricing_options_class.new(kit_item: true) }

        it "returns the normal price" do
          expect(subject.price_for_options(pricing_options).amount).to eq 2.00
        end
      end
    end
  end
end
