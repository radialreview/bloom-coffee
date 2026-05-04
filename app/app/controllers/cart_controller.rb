class CartController < ApplicationController
  def show
    @order = current_order
    @order_items = @order ? @order.order_items.includes(:drink, :add_ons) : []
  end
end
