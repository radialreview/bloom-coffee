class AddPublicTokenToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :public_token, :string
    add_index :orders, :public_token, unique: true
  end
end
