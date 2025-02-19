class ChangeDescriptionTypeInComplains < ActiveRecord::Migration[7.0]
  def change
    change_column :complains, :description, :text
    change_column :complains, :reply, :text
  end
end
