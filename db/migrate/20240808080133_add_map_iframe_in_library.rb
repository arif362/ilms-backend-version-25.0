class AddMapIframeInLibrary < ActiveRecord::Migration[7.0]
  def change
    add_column :libraries, :map_iframe, :text
  end
end
