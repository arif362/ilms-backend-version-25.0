# frozen_string_literal: true

module PublicLibrary
  class HomepageSliders < PublicLibrary::Base
    resources :homepage_sliders do
      desc 'Homepage Sliders List'
      params do
        use :pagination, per_page: 25
      end
      route_setting :authentication, optional: true
      get do
        homepage_sliders = HomepageSlider.not_deleted.visible.all
        PublicLibrary::Entities::HomepageSliders.represent(homepage_sliders.order(serial_no: :asc), request_source: @request_source)
      end
    end
  end
end
