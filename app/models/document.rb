class Document < ApplicationRecord
  has_one_attached :document
  belongs_to :document_category, foreign_key: :document_category_id
  validates :name, presence: true, uniqueness: true


  def document_file=(file)
    return if file.blank?

    document.attach(io: file[:tempfile],
                    filename: file[:filename],
                    content_type: file[:type])
  end
end
