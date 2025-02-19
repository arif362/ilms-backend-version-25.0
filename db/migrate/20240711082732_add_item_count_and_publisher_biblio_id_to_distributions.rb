class AddItemCountAndPublisherBiblioIdToDistributions < ActiveRecord::Migration[7.0]
  def change
    add_column :distributions, :item_count, :integer
  end
end
