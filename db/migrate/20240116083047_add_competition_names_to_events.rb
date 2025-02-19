class AddCompetitionNamesToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :competition_info, :text
  end
end
