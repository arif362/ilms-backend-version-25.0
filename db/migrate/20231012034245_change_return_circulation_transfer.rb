class ChangeReturnCirculationTransfer < ActiveRecord::Migration[7.0]
  def change
    remove_column :return_circulation_transfers, :status, :integer, default: 0
    add_column :return_circulation_transfers, :return_circulation_status_id, :bigint
  end
end
