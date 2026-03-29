class AddUniqueIndexToOrderItemAddOns < ActiveRecord::Migration[8.0]
  def change
    add_index :order_item_add_ons, [ :order_item_id, :add_on_id ], unique: true
  end
end
