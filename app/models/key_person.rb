# frozen_string_literal: true

class KeyPerson < ApplicationRecord
  validates :name, :bn_name, :designation, :bn_designation, :description, :bn_description, presence: true
  validates :position, presence: true, numericality: { greater_than: 0 }
  scope :active, -> { where(is_active: true) }
  scope :not_deleted, -> { where(is_deleted: false) }
  has_one_attached :image do |attachable|
    attachable.variant :desktop_large, resize_to_limit: [289, 340]
    attachable.variant :tab_large, resize_to_limit: [150, 194]
    attachable.variant :mobile_large, resize_to_limit: [500, 500]
  end

  before_create :set_slug
  def image_file=(file)
    return if file.blank?

    image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end

  def check_slug_uniqueness(slug_param)
    key_people = KeyPerson.where(slug: slug_param)
    return true if key_people.empty?

    return true if key_people.count == 1 && key_people.ids.include?(id)

    false
  end

  private

  def set_slug
    slug = name.to_s.parameterize
    self.slug = KeyPerson.find_by(slug:).present? ? "#{slug}-#{KeyPerson.all.count + 1}" : slug
  end
end
