class AddReferenceNoToLibraryTransferOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :library_transfer_orders, :reference_no, :string
  end
end
