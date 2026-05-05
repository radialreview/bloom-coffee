class CreateAddOns < ActiveRecord::Migration[8.1]
  def change
    create_table :add_ons do |t|
      t.string :name, null: false
      t.decimal :price, precision: 8, scale: 2, null: false
      t.timestamps
    end
  end
end
