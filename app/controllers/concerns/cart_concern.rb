module CartConcern
  extend ActiveSupport::Concern

  included do
    helper_method :current_order
  end

  private

  def current_order
    @current_order ||= find_or_create_order
  end

  def find_or_create_order
    order = Order.find_by(id: session[:order_id], status: :cart) if session[:order_id]
    return order if order

    order = Order.create!(status: :cart)
    session[:order_id] = order.id
    order
  end
end
