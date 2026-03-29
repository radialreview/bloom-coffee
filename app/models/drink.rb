class Drink < ApplicationRecord
  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }
end
