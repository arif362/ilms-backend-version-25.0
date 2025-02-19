# frozen_string_literal: true

module Admin
  class Pages < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::PageParams
    resources :pages do

      desc 'Page List'
      params do
        use :pagination, per_page: 25
        optional :skip_pagination, type: Boolean, default: false
        optional :title, type: String
      end

      get do
        pages = Page.order(id: :desc)
        if params[:title].present?
          pages = pages.where('lower(title) LIKE ?', "%#{params[:title].downcase}%").order(id: :desc)
        end
        authorize pages, :read?
        Admin::Entities::Pages.represent(paginate(pages), except: %i[banner_url is_active])
      end


      desc 'Create page'
      params do
        use :page_create_params
      end

      post do
        page = Page.new(declared(params, include_missing: false))
        authorize page, :create?
        page.save!
        Admin::Entities::Pages.represent(page, all: true)
      end

      route_param :id do
        desc 'page Details'

        get do
          page = Page.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless page.present?
          authorize page, :read?
          Admin::Entities::Pages.represent(page)
        end

        desc 'page Update'
        params do
          use :page_update_params
        end

        put do
          page = Page.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless page.present?
          authorize page, :update?

          page.update!(declared(params, include_missing: false).except(:slug).merge(slug: params[:slug].to_s.parameterize))
          Admin::Entities::Pages.represent(page, all: true)
        end

        desc 'page Delete'
        delete do
          page = Page.deletable.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless page.present?
          authorize page, :delete?

          page.destroy!
        end
      end
    end
  end
end
