class AddDistrictIdToLibrary < ActiveRecord::Migration[7.0]
  def change
    add_reference :libraries, :district, index: true, foreign_key: true
  end
end
