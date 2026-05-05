class OrderItemAddOn < ActiveRecord::Base
  belongs_to :order_item
  belongs_to :add_on

  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
