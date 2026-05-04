class IndexDrinksOnLowerName < ActiveRecord::Migration[8.0]
  def up
    remove_index :drinks, :name
    execute <<~SQL.squish
      CREATE UNIQUE INDEX index_drinks_on_lower_name ON drinks (LOWER(name))
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS index_drinks_on_lower_name"
    add_index :drinks, :name, unique: true
  end
end
