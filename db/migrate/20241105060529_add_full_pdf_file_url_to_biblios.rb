class AddFullPdfFileUrlToBiblios < ActiveRecord::Migration[7.0]
  def change
    add_column :biblios, :full_pdf_file_url, :string
  end
end
