class OrdersController < ApplicationController
  def create
    @order = current_order

    if @order.order_items.empty?
      redirect_to cart_path, alert: "Your order is empty. Add some drinks first!"
      return
    end

    @order.customer_name = order_params[:customer_name]
    @order.status = :submitted

    if @order.save
      session.delete(:order_id)
      redirect_to order_path(@order)
    else
      @order.status = :cart
      redirect_to cart_path, alert: "Please provide your name for pickup."
    end
  end

  def show
    @order = Order.submitted.find_by!(confirmation_token: params[:id])
    @order_items = @order.order_items.includes(:drink, :add_ons)
  end

  private

  def order_params
    params.require(:order).permit(:customer_name)
  end
end
