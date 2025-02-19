class AddIsMachineToCirculation < ActiveRecord::Migration[7.0]
  def change
    add_column :circulations, :is_machine, :boolean, default: false
  end
end
