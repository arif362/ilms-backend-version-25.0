class CreateBiblioWishlists < ActiveRecord::Migration[7.0]
  def change
    create_table :biblio_wishlists do |t|
      t.references :biblio
      t.references :user

      t.timestamps
    end
  end
end
