class IndexAddOnsOnLowerName < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL.squish
      CREATE UNIQUE INDEX index_add_ons_on_lower_name ON add_ons (LOWER(name))
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS index_add_ons_on_lower_name"
  end
end
