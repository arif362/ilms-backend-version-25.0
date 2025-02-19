# frozen_string_literal: true

module Admin
  class PageBanners < Admin::Base
    resources :page_banners do
      include Admin::Helpers::AuthorizationHelpers
      helpers Admin::QueryParams::BannerParams
      desc 'Banner List'
      params do
        use :pagination, per_page: 25
      end
      get do
        banners = Banner.not_deleted.all
        authorize banners, :read?
        Admin::Entities::Banners.represent(paginate(banners.order(id: :desc)))
      end

      desc 'Create banner'
      params do
        use :banner_create_params
      end

      post do
        error!('Position must be positive', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:position].positive?
        page_type = PageType.find_by(id: params[:page_type_id])
        error!('Page type not found', HTTP_CODE[:NOT_ACCEPTABLE]) unless page_type.present?
        banner = Banner.new(declared(params, include_missing: false))
        authorize banner, :create?
        Admin::Entities::Banners.represent(banner) if banner.save!
      end

      route_param :id do
        desc 'Banner Details'

        get do
          banner = Banner.not_deleted.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless banner.present?
          authorize banner, :read?
          Admin::Entities::Banners.represent(banner)
        end

        desc 'Update banner'
        params do
          use :banner_update_params
        end

        put do
          banner = Banner.not_deleted.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless banner.present?
          error!('Position must be positive', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:position].positive?
          page_type = PageType.find_by(id: params[:page_type_id])
          error!('Page type not found', HTTP_CODE[:NOT_ACCEPTABLE]) unless page_type.present?
          authorize banner, :update?
          banner.update!(declared(params, include_missing: false))
          Admin::Entities::Banners.represent(banner)
        end

        desc 'Banner delete'

        delete do
          banner = Banner.not_deleted.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless banner.present?
          authorize banner, :delete?
          banner.update!(is_deleted: true)
          status HTTP_CODE[:OK]
        end
      end
    end
  end
end
