class Drink < ActiveRecord::Base
  MAX_NAME_LENGTH = 120
  MAX_DESCRIPTION_LENGTH = 500
  MAX_BASE_PRICE = 999_999.99

  has_many :order_items, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true, length: { maximum: MAX_NAME_LENGTH }
  validates :description, length: { maximum: MAX_DESCRIPTION_LENGTH }
  validates :base_price, numericality: { greater_than: 0, less_than_or_equal_to: MAX_BASE_PRICE }

  def as_api_json
    {
      id: id,
      name: name,
      description: description.to_s,
      base_price: base_price.to_f.round(2),
    }
  end
end
