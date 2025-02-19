class AddAndRemoveColumnsToOtps < ActiveRecord::Migration[7.0]
  def change
    add_column :otps, :otp_type, :integer
    remove_columns :otps, :api_request, :api_response
  end
end
