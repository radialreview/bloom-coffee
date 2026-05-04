class AddOn < ActiveRecord::Base
  MAX_NAME_LENGTH = 120
  MAX_PRICE = 999_999.99

  has_many :order_item_add_ons, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true, length: { maximum: MAX_NAME_LENGTH }
  validates :price, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PRICE }

  def as_api_json
    {
      id: id,
      name: name,
      price: price.to_f.round(2),
    }
  end
end
