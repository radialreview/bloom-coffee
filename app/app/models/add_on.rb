class AddOn < ApplicationRecord
  has_many :order_item_add_ons, dependent: :restrict_with_exception

  validates :name, presence: true, length: { maximum: 80 }, uniqueness: { case_sensitive: false }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
