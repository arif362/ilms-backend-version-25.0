class AddReturnRctToBiblioLibrary < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_libraries, :return_rct_3pl_quantity, :integer, default: 0
  end
end
