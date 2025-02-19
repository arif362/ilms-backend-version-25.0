# frozen_string_literal: true

class ChangeDateOfPublicationFromStringToDatetimeInBiblios < ActiveRecord::Migration[7.0]
  def up
    change_column :biblios, :date_of_publication, :datetime
  end

  def down
    change_column :biblios, :date_of_publication, :string
  end
end
