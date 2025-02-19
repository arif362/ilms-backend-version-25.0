# frozen_string_literal: true

module Admin
  class PageTypes < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::PageTypeParams
    resources :page_types do
      desc 'Page type List'
      get do
        page_types = PageType.all.order(id: :desc)
        Admin::Entities::PageTypes.represent(page_types)
      end

      desc 'Create page type'
      params do
        use :page_type_create_params
      end

      post do
        page_type = PageType.new(declared(params, include_missing: false))
        authorize page_type, :create?
        Admin::Entities::PageTypes.represent(page_type) if page_type.save!
      end

      route_param :id do

        desc 'page details'

        get do
          page_type = PageType.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless page_type.present?
          authorize page_type, :read?
          Admin::Entities::PageTypes.represent(page_type)
        end


        desc 'Update page type'
        params do
          use :page_type_update_params
        end

        put do
          page_type = PageType.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless page_type.present?
          authorize page_type, :update?
          page_type.update!(declared(params, include_missing: false))
          Admin::Entities::PageTypes.represent(page_type)
        end

        desc 'page_type delete'

        delete do
          page_type = PageType.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless page_type.present?
          error!('Has associated banners', HTTP_CODE[:NOT_ACCEPTABLE]) unless page_type.banners.blank?
          authorize page_type, :delete?
          page_type.destroy!
          { message: 'Successfully deleted' }
        end
      end
    end
  end
end
