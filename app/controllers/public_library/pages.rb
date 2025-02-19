# frozen_string_literal: true

module PublicLibrary
  class Pages < PublicLibrary::Base
    resources :pages do

      route_setting :authentication, optional: true
      route_param :slug do
        desc 'page Details'
        get do
          page = Page.active.find_by(slug: params[:slug])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless page.present?
          PublicLibrary::Entities::Pages.represent(page, locale: @locale)
        end
      end
    end
  end
end
