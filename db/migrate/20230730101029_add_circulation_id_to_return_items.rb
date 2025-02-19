class AddCirculationIdToReturnItems < ActiveRecord::Migration[7.0]
  def change
    add_column :return_items, :circulation_id, :integer
  end
end
