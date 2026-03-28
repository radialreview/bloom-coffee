class AddUniqueIndexesToDrinksAndAddOns < ActiveRecord::Migration[8.0]
  def change
    add_index :drinks, :name, unique: true
    add_index :add_ons, :name, unique: true
  end
end
