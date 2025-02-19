class SavedAddress < ApplicationRecord
  belongs_to :user
  belongs_to :division, optional: true
  belongs_to :district, optional: true
  belongs_to :thana, optional: true
  belongs_to :updated_by, polymorphic: true, optional: true
  belongs_to :created_by, polymorphic: true, optional: true

  validates :name, :address, :delivery_area, :delivery_area_id, presence: true
  validates :recipient_phone, length: { is: 11 },
                              numericality: { only_integer: true },
                              format: { with: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/, message: 'Not a valid phone number' },
                              allow_blank: true

  enum address_type: { others: 0, permanent: 1, present: 2 }

  def self.add_address(user, name, address, division_id, district_id, thana_id, recipient_name, recipient_phone, delivery_area_id, delivery_area, address_type='others')
    user.saved_addresses.create!(
      name:,
      address:,
      division_id:,
      district_id:,
      thana_id:,
      recipient_name:,
      recipient_phone:,
      delivery_area_id:,
      delivery_area:,
      address_type:
    )
  end
end
