class OrdersController < ApplicationController
  def index
    @last_order = Order.submitted.find_by(id: session[:last_order_id])
    @order_items = @last_order&.order_items&.includes(:drink, :add_ons) || []
  end

  def create
    @order = current_order

    if @order.nil? || @order.order_items.empty?
      redirect_to cart_path, alert: "Your cart is empty. Add some drinks first!"
      return
    end

    @order.customer_name = order_params[:customer_name]
    @order.status = :submitted

    if @order.save
      session.delete(:order_id)
      session[:last_order_id] = @order.id
      redirect_to order_path(@order)
    else
      @order.status = :in_progress
      redirect_to cart_path, alert: "Please provide your name for pickup."
    end
  end

  def show
    @order = Order.submitted.find(params[:id])
    @order_items = @order.order_items.includes(:drink, :add_ons)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  private

  def order_params
    params.require(:order).permit(:customer_name)
  end
end
