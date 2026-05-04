class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :drink
  has_many :order_item_add_ons, dependent: :destroy
  has_many :add_ons, through: :order_item_add_ons

  validates :quantity, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 20 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :line_total, numericality: { greater_than_or_equal_to: 0 }

  def as_api_json
    {
      drink: {
        id: drink_id,
        name: drink.name,
      },
      quantity: quantity,
      unit_price: unit_price.to_f.round(2),
      add_ons: order_item_add_ons.map do |record|
        {
          id: record.add_on_id,
          name: record.add_on.name,
          price: record.price.to_f.round(2),
        }
      end,
      line_total: line_total.to_f.round(2),
    }
  end
end
