class AddOn < ApplicationRecord
  has_many :order_item_add_ons, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }
end
