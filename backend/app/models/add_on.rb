class AddOn < ActiveRecord::Base
  has_many :order_item_add_ons, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  def as_api_json
    {
      id: id,
      name: name,
      price: price.to_f.round(2),
    }
  end
end
