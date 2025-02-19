class ChangeColumnsInRequestedBiblio < ActiveRecord::Migration[7.0]
  def change
    reversible do |rb|
      rb.up do
        rename_column :requested_biblios, :author_name, :authors_name
        change_column :requested_biblios, :authors_name, :text
        rename_column :requested_biblios, :biblio_subject, :biblio_subjects_name
        change_column :requested_biblios, :biblio_subjects_name, :text
        remove_column :requested_biblios, :other_authors, :string
      end
      rb.down do
        change_column :requested_biblios, :authors_name, :string
        rename_column :requested_biblios, :authors_name, :author_name
        change_column :requested_biblios, :biblio_subjects_name, :string
        rename_column :requested_biblios, :biblio_subjects_name, :biblio_subject
        add_column :requested_biblios, :other_authors, :string
      end
    end
  end
end
