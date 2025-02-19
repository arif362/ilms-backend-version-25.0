class AddColumnsToRequestedBiblio < ActiveRecord::Migration[7.0]
  def change
    add_column :requested_biblios, :possible_availability_at, :datetime
  end
end
