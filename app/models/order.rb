class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  enum :status, { cart: 0, submitted: 1 }

  validates :customer_name, presence: true, if: :submitted?

  before_save :generate_confirmation_token, if: -> { submitted? && confirmation_token.blank? }

  def to_param
    confirmation_token || id.to_s
  end

  def total
    base_total = order_items.joins(:drink).sum("order_items.quantity * drinks.base_price")
    add_on_total = order_items.joins(order_item_add_ons: :add_on).sum("order_items.quantity * add_ons.price")
    base_total + add_on_total
  end

  def item_count
    order_items.sum(:quantity)
  end

  def order_number
    "##{id}"
  end

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(16)
  end
end
