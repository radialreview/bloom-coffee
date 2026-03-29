class CreateDrinks < ActiveRecord::Migration[8.0]
  def change
    create_table :drinks do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :base_price, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
