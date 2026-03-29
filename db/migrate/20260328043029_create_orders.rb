class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.integer :status, null: false, default: 0
      t.string :customer_name

      t.timestamps
    end
  end
end
