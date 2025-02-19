class DocumentCategory < ApplicationRecord

  belongs_to :staff, foreign_key: :created_by
  has_many :documents, dependent: :restrict_with_exception
  validates :name, presence: true, uniqueness: true

end
