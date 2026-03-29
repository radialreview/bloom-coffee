class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  enum :status, { cart: 0, submitted: 1 }

  validates :customer_name, presence: true, if: :submitted?

  def total
    base_total = order_items
      .joins(:drink)
      .sum("drinks.base_price * order_items.quantity")

    add_on_total = order_items
      .left_joins(:add_ons)
      .sum("COALESCE(add_ons.price, 0) * order_items.quantity")

    base_total + add_on_total
  end

  def item_count
    order_items.sum(:quantity)
  end

  def order_number
    "##{id}"
  end
end
