class DepartmentBiblioItem < ApplicationRecord
  audited
  belongs_to :goods_receipt, optional: true
  belongs_to :publisher_biblio, optional: true
  belongs_to :po_line_item, optional: true
  belongs_to :library, optional: true
  belongs_to :department_biblio_item_status, optional: true
  has_many :dep_biblio_item_status_changes
  belongs_to :updated_by, polymorphic: true, optional: true

  after_update :create_dep_biblio_item_status_change, if: -> { saved_change_to_library_id? && library_id.present? }

  after_create :central_accession_number
  def central_accession_number
    update_column(:central_accession_no, "1#{id.to_s.rjust(9, '0')}")
  end

  private

  def create_dep_biblio_item_status_change
    dep_biblio_item_status_changes.create!(department_biblio_item_status_id:,
                                           changed_by: updated_by)
  end


end
