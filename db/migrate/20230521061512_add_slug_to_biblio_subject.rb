# frozen_string_literal: true

class AddSlugToBiblioSubject < ActiveRecord::Migration[7.0]
  def change
    add_column :biblio_subjects, :slug, :string, null: false
  end
end
