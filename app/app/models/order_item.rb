class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :drink
  has_many :order_item_add_ons, dependent: :destroy
  has_many :add_ons, through: :order_item_add_ons

  accepts_nested_attributes_for :order_item_add_ons,
    reject_if: proc { |attrs| attrs["add_on_id"].blank? }

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  def unit_price
    drink.price + add_ons.map(&:price).sum
  end

  def line_total
    unit_price * quantity
  end
end
