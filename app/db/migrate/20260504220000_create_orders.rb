class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.integer :status, default: 0, null: false
      t.string :customer_name
      t.decimal :total_price, precision: 8, scale: 2

      t.timestamps
    end
  end
end
