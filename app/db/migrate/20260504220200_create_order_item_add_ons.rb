class CreateOrderItemAddOns < ActiveRecord::Migration[8.0]
  def change
    create_table :order_item_add_ons do |t|
      t.references :order_item, null: false, foreign_key: true
      t.references :add_on, null: false, foreign_key: true

      t.timestamps
    end

    add_index :order_item_add_ons, %i[order_item_id add_on_id], unique: true, name: "idx_oiao_unique_pair"
  end
end
