class CreateAddOns < ActiveRecord::Migration[8.0]
  def change
    create_table :add_ons do |t|
      t.string :name, null: false
      t.decimal :price, precision: 6, scale: 2, null: false

      t.timestamps
    end
  end
end
