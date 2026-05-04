module CartConcern
  extend ActiveSupport::Concern

  included do
    helper_method :current_order, :cart_item_count
  end

  private

  def current_order
    return @_current_order if defined?(@_current_order)

    @_current_order =
      if session[:order_id].blank?
        nil
      else
        order = Order.find_by(id: session[:order_id], status: :in_progress)
        if order
          order
        else
          session.delete(:order_id)
          nil
        end
      end
  end

  def current_or_create_order
    @current_order ||= find_or_create_order
  end

  def cart_item_count
    order = current_order
    order ? order.item_count : 0
  end

  def find_or_create_order
    existing = current_order
    return existing if existing

    order = Order.create!(status: :in_progress)
    session[:order_id] = order.id
    @_current_order = order
    order
  end
end
