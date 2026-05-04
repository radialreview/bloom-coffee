class AddOn < ApplicationRecord
  validates :name, presence: true, length: { maximum: 80 }, uniqueness: { case_sensitive: false }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
