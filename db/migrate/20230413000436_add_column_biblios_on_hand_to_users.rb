class AddColumnBibliosOnHandToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :biblios_on_hand, :integer, default: 0, null: false
  end
end
