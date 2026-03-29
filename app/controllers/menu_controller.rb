class MenuController < ApplicationController
  def index
    @drinks = Drink.order(:name)
  end

  def show
    @drink = Drink.find(params[:id])
    @add_ons = AddOn.order(:name)
  end
end
