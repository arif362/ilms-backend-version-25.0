# frozen_string_literal: true

module PublicLibrary
  class PageBanners < PublicLibrary::Base
    resources :page_banners do

      route_param :slug do
        desc 'Banner Details'
        route_setting :authentication, optional: true
        get do
          banner = Banner.not_deleted.visible.find_by(slug: params[:slug])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless banner.present?
          PublicLibrary::Entities::Banners.represent(banner, locale: @locale, request_source: @request_source)
        end
      end
    end
  end
end
