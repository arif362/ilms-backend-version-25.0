class CirculationStatusChange < ApplicationRecord
  belongs_to :circulation
  belongs_to :circulation_status
  belongs_to :changed_by, polymorphic: true, optional: true
end
