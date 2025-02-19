class AddRedxAreaIdToLibraries < ActiveRecord::Migration[7.0]
  def change
    add_column :libraries, :redx_area_id, :integer
  end
end
