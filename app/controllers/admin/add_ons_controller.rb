# frozen_string_literal: true

class Admin::AddOnsController < Admin::BaseController
  before_action :set_add_on, only: %i[show edit update destroy]

  def index
    @add_ons = AddOn.order(:name)
  end

  def show
  end

  def new
    @add_on = AddOn.new
  end

  def create
    @add_on = AddOn.new(add_on_params)

    if @add_on.save
      redirect_to admin_add_ons_path, notice: "Add-on was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @add_on.update(add_on_params)
      redirect_to admin_add_ons_path, notice: "Add-on was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @add_on.destroy
      redirect_to admin_add_ons_path, notice: "Add-on was successfully deleted."
    else
      redirect_to admin_add_ons_path, alert: "There was a problem deleting this add-on."
    end
  end

  private

  def set_add_on
    @add_on = AddOn.find(params[:id])
  end

  def add_on_params
    params.require(:add_on).permit(:name, :price)
  end
end
