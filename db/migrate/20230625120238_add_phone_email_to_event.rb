class AddPhoneEmailToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :phone, :string
    add_column :events, :email, :string
  end
end
