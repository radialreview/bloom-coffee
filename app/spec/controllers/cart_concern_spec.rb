require "rails_helper"

RSpec.describe CartConcern, type: :controller do
  controller(ApplicationController) do
  end

  describe "current_order memoization with find_or_create_order" do
    it "returns the persisted order after current_order memoized nil and session is set in the same request" do
      session[:order_id] = nil

      expect(controller.send(:current_order)).to be_nil

      created = controller.send(:find_or_create_order)
      expect(created).to be_persisted

      expect(controller.send(:current_order)).to eq(created)
      expect(controller.send(:current_order).id).to eq(session[:order_id])
    end
  end
end
