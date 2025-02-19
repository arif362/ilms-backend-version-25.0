class AddDistributionIdToDepartmentBiblioItems < ActiveRecord::Migration[7.0]
  def change
    add_column :department_biblio_items, :distribution_id, :integer
  end
end
