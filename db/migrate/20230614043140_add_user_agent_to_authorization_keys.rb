class AddUserAgentToAuthorizationKeys < ActiveRecord::Migration[7.0]
  def change
    add_column :authorization_keys, :user_agent, :string
  end
end
