class AddLibraryIdToDistribution < ActiveRecord::Migration[7.0]
  def change
    add_column :distributions, :library_id, :integer
  end
end
