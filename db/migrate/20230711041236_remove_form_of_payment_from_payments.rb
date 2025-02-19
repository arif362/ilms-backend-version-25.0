class RemoveFormOfPaymentFromPayments < ActiveRecord::Migration[7.0]
  def change
    remove_column :payments, :form_of_payment, :string
  end
end
