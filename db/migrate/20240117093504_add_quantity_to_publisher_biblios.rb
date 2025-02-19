class AddQuantityToPublisherBiblios < ActiveRecord::Migration[7.0]
  def change
    add_column :publisher_biblios, :quantity, :integer, default: 0
  end
end
