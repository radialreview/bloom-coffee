class Drink < ActiveRecord::Base
  has_many :order_items, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :base_price, numericality: { greater_than: 0 }

  def as_api_json
    {
      id: id,
      name: name,
      description: description.to_s,
      base_price: base_price.to_f.round(2),
    }
  end
end
