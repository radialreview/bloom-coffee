class OrderItemAddOn < ApplicationRecord
  belongs_to :order_item
  belongs_to :add_on

  validates :add_on_id, uniqueness: { scope: :order_item_id }
end
