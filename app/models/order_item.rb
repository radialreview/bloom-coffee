class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :drink
  has_many :order_item_add_ons, dependent: :destroy
  has_many :add_ons, through: :order_item_add_ons

  accepts_nested_attributes_for :order_item_add_ons, reject_if: :duplicate_add_on?

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  def unit_price
    drink.base_price + add_ons.sum(:price)
  end

  def line_total
    unit_price * quantity
  end

  private

  def duplicate_add_on?(attributes)
    add_on_id = attributes["add_on_id"] || attributes[:add_on_id]
    return false unless add_on_id

    @seen_add_on_ids ||= Set.new
    !@seen_add_on_ids.add?(add_on_id.to_i)
  end
end
