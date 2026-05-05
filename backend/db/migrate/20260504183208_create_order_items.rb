class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :drink, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 8, scale: 2, null: false
      t.decimal :line_total, precision: 10, scale: 2, null: false
      t.timestamps
    end
  end
end
