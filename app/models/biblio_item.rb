class BiblioItem < ApplicationRecord
  enum biblio_item_type: { paper_biblio: 0, e_biblio: 1 }
  enum item_collection_type: { department: 0, library: 1, existing: 2 }
  belongs_to :biblio
  belongs_to :library
  belongs_to :permanent_library_location, class_name: 'LibraryLocation'
  belongs_to :current_library_location, class_name: 'LibraryLocation', optional: true
  belongs_to :shelving_library_location, class_name: 'LibraryLocation', optional: true
  belongs_to :biblio_classification_source, foreign_key: :biblio_classification_id, optional: true
  belongs_to :biblio_status, optional: true
  has_many :circulations, dependent: :restrict_with_exception
  has_many :line_items, dependent: :restrict_with_exception
  has_one :lost_damaged_biblio, dependent: :restrict_with_exception
  has_many :physical_reviews, dependent: :restrict_with_exception
  has_many :stock_changes, dependent: :restrict_with_exception
  has_many :rebind_biblios, dependent: :restrict_with_exception
  has_many :other_library_biblios, dependent: :restrict_with_exception
  has_many :lto_line_items, dependent: :restrict_with_exception

  validates :barcode, presence: true, uniqueness: true
  validates_uniqueness_of :accession_no, scope: :library_id
  validates :price, presence: true, numericality: { greater_than: 0 }, unless: :not_for_loan

  scope :for_borrow, -> { where(not_for_loan: false) }

  after_create :update_availability, :add_central_accession, unless: :e_biblio?
  after_save :update_biblio

  private
  def add_central_accession
    return unless existing?

    library.department_biblio_items.create(department_biblio_item_status: DepartmentBiblioItemStatus.get_status('received'),
                                           central_accession_no:, updated_by_id: updated_by_id,updated_by_type: 'Staff', biblio_item_id: id,
                                           is_existing_item: true)

  end

  def update_availability
    biblio_library = biblio.biblio_libraries.find_or_create_by!(library_id: library.id)
    if shelving_library_location.present?
      biblio_library.biblio_library_locations.find_or_create_by!(biblio_id:, library_location_id: shelving_library_location_id).increment_quantity
    end

    if not_for_loan
      biblio_library.increment!(:not_for_borrow_quantity)
    else
      biblio_library.increment!(:available_quantity)
    end
    biblio_library.save_stock_change('biblio_item_assign_by_library', 1, self,
                                     nil, 'available_quantity_change')
  end

  def update_biblio
    if e_biblio?
      biblio.update!(is_e_biblio: true) unless biblio.is_e_biblio
    else
      biblio.update!(is_paper_biblio: true) unless  biblio.is_paper_biblio
    end
  end
end
