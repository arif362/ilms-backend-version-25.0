# frozen_string_literal: true

module PublicLibrary
  class Divisions < PublicLibrary::Base
    resources :divisions do
      desc 'District List'
      params do
        use :pagination, per_page: 25
      end
      route_setting :authentication, optional: true
      get do
        divisions = Division.joins(districts: { thanas: :library }).distinct
        PublicLibrary::Entities::Divisions.represent(divisions, locale: @locale)
      end
    end
  end
end
