class Cart::ItemsController < ApplicationController
  def create
    @order = current_or_create_order
    @order_item = @order.order_items.build(order_item_params)

    if @order_item.save
      redirect_to cart_path, notice: "#{@order_item.drink.name} added to your order."
    else
      redirect_to menu_path(@order_item.drink || Drink.first), alert: "Could not add item to order."
    end
  end

  def update
    order = current_order
    return redirect_to(cart_path, alert: "Your cart is empty.") unless order

    @order_item = order.order_items.find(params[:id])
    new_quantity = params[:quantity].to_i

    if new_quantity > 0 && @order_item.update(quantity: new_quantity)
      redirect_to cart_path
    else
      redirect_to cart_path, alert: "Quantity must be at least 1."
    end
  end

  def destroy
    order = current_order
    return redirect_to(cart_path, alert: "Your cart is empty.") unless order

    @order_item = order.order_items.find(params[:id])

    if @order_item.destroy
      redirect_to cart_path, notice: "Item removed from your order."
    else
      redirect_to cart_path, alert: "Could not remove item from your order."
    end
  end

  private

  def order_item_params
    params.require(:order_item).permit(:drink_id, :quantity, order_item_add_ons_attributes: [ :add_on_id ])
  end
end
