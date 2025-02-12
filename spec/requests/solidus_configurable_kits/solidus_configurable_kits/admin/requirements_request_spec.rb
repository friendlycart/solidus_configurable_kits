require "spec_helper"

RSpec.describe "SolidusConfigurableKits::Admin::Requirements", type: :request do
  let(:product) { create(:product) }

  stub_authorization!

  describe "GET /index" do
    it "returns http success" do
      get "/admin/products/#{product.slug}/kit_requirements"
      expect(response).to have_http_status(:success)
    end
  end
end
