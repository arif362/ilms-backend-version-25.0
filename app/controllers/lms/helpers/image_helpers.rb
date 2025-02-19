# frozen_string_literal: true

module Lms::Helpers

  module ImageHelpers
    extend Grape::API::Helpers
    include Rails.application.routes.url_helpers

    def image_path(image)
      image.url if image.attached?
    rescue StandardError
      ''
    end

    def mobile_large_image(image)
      image.variant(:mobile_large)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end

    def video_preview(video)
      video.url if video.attached?
    rescue StandardError
      ''
    end

    def mobile_cart_image(image)
      image.variant(:mobile_cart)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end

    def desktop_cart_image(image)
      image.variant(:desktop_cart)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end

    def tab_cart_image(image)
      image.variant(:tab_cart)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end
  end
end
