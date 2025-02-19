# frozen_string_literal: true

module PublicLibrary
  class PageTypes < PublicLibrary::Base
    resources :page_types do
      desc 'Page type List'
      route_setting :authentication, optional: true
      get do
        page_types = PageType.all.order(title: :asc)
        PublicLibrary::Entities::PageTypes.represent(page_types)
      end
    end
  end
end
