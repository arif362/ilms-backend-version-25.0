# frozen_string_literal: true

module PublicLibrary
  class Districts < PublicLibrary::Base
    resources :districts do
      desc 'District List'
      params do
        use :pagination, per_page: 25
        optional :division_id, type: Integer
      end
      route_setting :authentication, optional: true
      get do
        if params[:division_id].present?
          division = Division.find_by(id: params[:division_id])
          error!('Division Not Found', HTTP_CODE[:NOT_FOUND]) unless division.present?
        end

        districts = if division.present?
                      division.districts.joins(thanas: :library).not_deleted.order(name: :asc)
                    else
                      District.joins(thanas: :library).not_deleted.order(name: :asc)
                    end
        PublicLibrary::Entities::Districts.represent(districts.distinct, locale: @locale)
      end
    end
  end
end
