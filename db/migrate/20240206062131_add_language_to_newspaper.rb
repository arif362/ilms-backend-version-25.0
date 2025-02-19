class AddLanguageToNewspaper < ActiveRecord::Migration[7.0]
  def change
    add_column :newspapers, :language, :integer
  end
end
