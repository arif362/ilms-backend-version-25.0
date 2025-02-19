class AddBirthPlaceToAuthor < ActiveRecord::Migration[7.0]
  def change
    reversible do |bp|
      bp.up do
        change_column :authors, :dob, :integer
        add_column :authors, :pob, :string
        add_column :authors, :dod, :integer
      end
      bp.down do
        change_column :authors, :dob, :date
        remove_column :authors, :pob, :string
        remove_column :authors, :dod, :integer
      end
    end
  end
end
