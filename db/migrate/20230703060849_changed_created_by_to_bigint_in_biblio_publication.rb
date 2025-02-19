class ChangedCreatedByToBigintInBiblioPublication < ActiveRecord::Migration[7.0]
  def change
    reversible do |bp|
      bp.up do
        rename_column :biblio_publications, :created_by, :created_by_id
        change_column :biblio_publications, :created_by_id, :bigint
      end
      bp.down do
        change_column :biblio_publications, :created_by_id, :integer
        rename_column :biblio_publications, :created_by_id, :created_by
      end
    end
  end
end
