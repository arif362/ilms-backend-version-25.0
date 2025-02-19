class AddFieldsToComplain < ActiveRecord::Migration[7.0]
  def change
    add_column :complains, :phone, :string
    add_column :complains, :subject, :string
    add_column :complains, :email, :string
  end
end
