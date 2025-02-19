class ChangeColumnTypeInMembers < ActiveRecord::Migration[7.0]
  def change
    change_column :members, :identity_number, :string
  end
end
