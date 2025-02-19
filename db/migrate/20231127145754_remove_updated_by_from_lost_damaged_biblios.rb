class RemoveUpdatedByFromLostDamagedBiblios < ActiveRecord::Migration[7.0]
  def change
    remove_column :lost_damaged_biblios, :updated_by
  end
end
