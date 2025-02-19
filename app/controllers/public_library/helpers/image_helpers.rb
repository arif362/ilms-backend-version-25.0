module PublicLibrary::Helpers

  module ImageHelpers
    extend Grape::API::Helpers
    include Rails.application.routes.url_helpers

    def image_path(image)
      image.url if image.attached?
    rescue StandardError
      ''
    end

    # admin
    def thumb_image(image)
      image.variant(:thumb)&.processed&.url if image.attached?
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

    def mobile_cart_image(image)
      image.variant(:mobile_cart)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end

    def desktop_large_image(image)
      # image.variant(:desktop_large)&.processed&.url if image.attached?
      image.url if image.attached?
    rescue StandardError
      ''
    end

    def tab_large_image(image)
      image.variant(:tab_large)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end

    def mobile_large_image(image)
      image.variant(:mobile_large)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end

    def banner_image(image)
      image.variant(:banner)&.processed&.url if image.attached?
    rescue StandardError
      ''
    end

    def library_details_images(images)
      images&.map do |image|
        {
          small: image.variant(:small)&.processed&.url,
          large: image.variant(:large)&.processed&.url
        }
      rescue StandardError
        {
          small: '',
          large: ''
        }
      end
    end

    def library_admin_images(images)
      images&.map do |image|
        image.variant(:small)&.processed&.url
      rescue StandardError
        ''
      end
    end

    def mobile_cart_images(images)
      images&.map do |image|
        image.variant(:mobile_cart)&.processed&.url
      rescue StandardError
        ''
      end
    end

    def tab_cart_images(images)
      images&.map do |image|
        image.variant(:tab_cart)&.processed&.url
      rescue StandardError
        ''
      end
    end

    def desktop_cart_images(images)
      images&.map do |image|
        image.variant(:desktop_cart)&.processed&.url
      rescue StandardError
        ''
      end
    end

    def desktop_large_images(images)
      images&.map do |image|
        image.variant(:desktop_large)&.processed&.url
      rescue StandardError
        ''
      end
    end

    def tab_large_images(images)
      images&.map do |image|
        image.variant(:tab_large)&.processed&.url
      rescue StandardError
        ''
      end
    end

    def mobile_large_images(images)
      images&.map do |image|
        image.variant(:mobile_large)&.processed&.url
      rescue StandardError
        ''
      end
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
