class CreateOrderItemAddOns < ActiveRecord::Migration[8.1]
  def change
    create_table :order_item_add_ons do |t|
      t.references :order_item, null: false, foreign_key: true
      t.references :add_on, null: false, foreign_key: true
      t.decimal :price, precision: 8, scale: 2, null: false
      t.timestamps
    end
  end
end
