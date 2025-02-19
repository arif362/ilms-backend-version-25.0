# frozen_string_literal: true

module Admin::Helpers

  module ImageHelpers
    extend Grape::API::Helpers
    include Rails.application.routes.url_helpers
    def image_path(image)
      image.url if image.attached?
    rescue StandardError
      ''
    end

    def thumb_image(image)
      image.variant(:thumb)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end

    def mobile_large_image(image)
      image.variant(:mobile_large)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end

    def mobile_cart_image(image)
      image.variant(:mobile_cart)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end

    def mobile_cart_images(images)
      images&.map do |image|
        {
          id: image.id,
          link: image.variant(:mobile_cart)&.processed&.url
        }
      rescue StandardError
        ''
      end
    end

    def library_admin_images(images)
      images&.map do |image|
        {
          id: image.id,
          link: image.variant(:small)&.processed&.url
        }
      rescue StandardError
        ''
      end
    end

    def desktop_large_image(image)
      image.variant(:desktop_large)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end

    def complaint_images(images)
      video_type = %w[video/mp4 video/mkv video/avi video/mpeg-4 video/wmv video/webm]
      images&.map do |image|
        if video_type.include?(image.content_type.to_s)
          {
            id: image.id,
            link: image.url,
            is_video: true
          }
        else
          {
            id: image.id,
            link: image.variant(:large)&.processed&.url,
            is_video: false
          }
        end
      rescue StandardError
        ''
      end
    end
  end
end
