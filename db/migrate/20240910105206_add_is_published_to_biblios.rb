class AddIsPublishedToBiblios < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :is_published, :boolean, default: true
  end
end
