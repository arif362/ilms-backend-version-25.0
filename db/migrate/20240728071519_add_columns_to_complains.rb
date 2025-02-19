class AddColumnsToComplains < ActiveRecord::Migration[7.0]
  def change
    add_column :complains, :closed_or_resolved_at, :datetime
    add_column :complains, :closed_or_resolved_by_staff_id, :integer
    add_column :complains, :action_note, :text
  end
end
