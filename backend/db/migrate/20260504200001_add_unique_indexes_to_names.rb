class AddUniqueIndexesToNames < ActiveRecord::Migration[8.1]
  def change
    add_index :drinks, :name, unique: true
    add_index :add_ons, :name, unique: true
  end
end
