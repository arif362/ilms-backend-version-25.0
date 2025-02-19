class ChangeRegistrationFieldToEvent < ActiveRecord::Migration[7.0]
  def change
    change_column :events, :registration_fields, :text
  end
end
