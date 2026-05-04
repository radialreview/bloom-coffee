class PagesController < ApplicationController
  def index
    @drinks = Drink.order(:created_at)
  end
end
