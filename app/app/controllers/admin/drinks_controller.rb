class Admin::DrinksController < Admin::BaseController
  before_action :set_drink, only: %i[edit update destroy]

  def index
    @drinks = Drink.order(:created_at)
  end

  def new
    @drink = Drink.new
  end

  def edit
  end

  def create
    @drink = Drink.new(drink_params)
    if @drink.save
      flash.now[:notice] = "Created drink '#{@drink.name}'."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_drinks_path, notice: flash.now[:notice] }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @drink.update(drink_params)
      flash.now[:notice] = "Updated drink '#{@drink.name}'."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_drinks_path, notice: flash.now[:notice] }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @drink.destroy!
    flash.now[:notice] = "Deleted drink '#{@drink.name}'."
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_drinks_path, notice: flash.now[:notice] }
    end
  end

  private

  def set_drink
    @drink = Drink.find(params[:id])
  end

  def drink_params
    params.require(:drink).permit(:name, :description, :price)
  end
end
