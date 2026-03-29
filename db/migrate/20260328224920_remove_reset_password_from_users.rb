class RemoveResetPasswordFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_index :users, :reset_password_token, if_exists: true
    remove_column :users, :reset_password_token, :string, if_exists: true
    remove_column :users, :reset_password_sent_at, :datetime, if_exists: true
  end
end
