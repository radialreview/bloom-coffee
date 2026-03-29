# frozen_string_literal: true

class Admin::DrinksController < Admin::BaseController
  before_action :set_drink, only: %i[show edit update destroy]

  def index
    @drinks = Drink.order(:name)
  end

  def show
  end

  def new
    @drink = Drink.new
  end

  def create
    @drink = Drink.new(drink_params)

    if @drink.save
      redirect_to admin_drinks_path, notice: "Drink was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @drink.update(drink_params)
      redirect_to admin_drinks_path, notice: "Drink was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @drink.destroy
      redirect_to admin_drinks_path, notice: "Drink was successfully deleted."
    else
      redirect_to admin_drinks_path, alert: "There was a problem deleting this drink."
    end
  end

  private

  def set_drink
    @drink = Drink.find(params[:id])
  end

  def drink_params
    params.require(:drink).permit(:name, :description, :base_price)
  end
end
