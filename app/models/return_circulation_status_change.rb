class ReturnCirculationStatusChange < ApplicationRecord
  belongs_to :return_circulation_transfer
  belongs_to :return_circulation_status
  belongs_to :changed_by, polymorphic: true
end
