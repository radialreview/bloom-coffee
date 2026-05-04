class Drink < ApplicationRecord
  has_many :order_items, dependent: :restrict_with_exception

  validates :name, presence: true, length: { maximum: 80 }, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 10_000 }
end
