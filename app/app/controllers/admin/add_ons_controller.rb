class Admin::AddOnsController < Admin::BaseController
  before_action :set_add_on, only: %i[edit update destroy]

  def index
    @add_ons = AddOn.order(:created_at)
  end

  def new
    @add_on = AddOn.new
  end

  def edit
  end

  def create
    @add_on = AddOn.new(add_on_params)
    if @add_on.save
      flash.now[:notice] = "Created add-on '#{@add_on.name}'."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_add_ons_path, notice: flash.now[:notice] }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @add_on.update(add_on_params)
      flash.now[:notice] = "Updated add-on '#{@add_on.name}'."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_add_ons_path, notice: flash.now[:notice] }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @add_on.destroy!
    flash.now[:notice] = "Deleted add-on '#{@add_on.name}'."
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_add_ons_path, notice: flash.now[:notice] }
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
