class RenamePl3QuantityToThreePlQuantity < ActiveRecord::Migration[7.0]
  def change
    rename_column :biblio_libraries, :pl3_quantity, :three_pl_quantity
  end
end
