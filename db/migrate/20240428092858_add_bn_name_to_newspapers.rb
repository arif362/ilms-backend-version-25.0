class AddBnNameToNewspapers < ActiveRecord::Migration[7.0]
  def change
    add_column :newspapers, :bn_name, :string
  end
end
