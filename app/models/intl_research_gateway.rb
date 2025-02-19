class IntlResearchGateway < ApplicationRecord
  validates :name, :url,  presence: true
  scope :active, ->{ where(is_published:true, is_deleted:false)}
end
