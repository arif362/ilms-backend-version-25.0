# frozen_string_literal: true

class AlbumItem < ApplicationRecord
  belongs_to :album

  has_one_attached :image do |attachable|
    attachable.variant :desktop_cart, resize_to_limit: [183, 260]
    attachable.variant :tab_cart, resize_to_limit: [150, 194]
    attachable.variant :mobile_cart, resize_to_limit: [156, 230]
    attachable.variant :desktop_large, resize_to_limit: [500, 620]
    attachable.variant :tab_large, resize_to_limit: [150, 194]
    attachable.variant :mobile_large, resize_to_limit: [250, 320]
  end

  after_create :increment_album_total_items
  after_destroy :decrement_album_total_items
  def image_file=(file)
    return if file.blank?

    image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end

  private

  def increment_album_total_items
    album.update!(total_items: album.total_items + 1)
  end

  def decrement_album_total_items
    album.update!(total_items: album.total_items - 1)
  end
end
