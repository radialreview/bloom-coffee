class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :customer_name, null: false
      t.integer :order_number, null: false
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0
      t.timestamps
    end

    add_index :orders, :order_number, unique: true
  end
end
