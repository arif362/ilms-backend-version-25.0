# frozen_string_literal: true

module PublicLibrary
  class Thanas < PublicLibrary::Base
    resources :thanas do
      desc 'Thana List'
      params do
        use :pagination, per_page: 25
        optional :district_id, type: Integer
      end
      route_setting :authentication, optional: true
      get do
        if params[:district_id].present?
          district = District.find_by(id: params[:district_id])
          error!('District Not Found', HTTP_CODE[:NOT_FOUND]) unless district.present?
        end

        thanas = if district.present?
                   district.thanas.joins(:library).not_deleted.order(name: :asc)
                 else
                   Thana.joins(:library).not_deleted.order(name: :asc)
                 end
        PublicLibrary::Entities::Thanas.represent(paginate(thanas), locale: @locale)
      end

      route_param :id do
        desc 'Library find by thana'
        route_setting :authentication, optional: true
        get do
          thana = Thana.find_by(id: params[:id])
          error!('Thana not found', HTTP_CODE[:NOT_FOUND]) unless thana.present?

          library = thana&.library.present? ? thana&.library : thana.district.library_from_district(thana)
          PublicLibrary::Entities::LibraryDropdown.represent(library)
        end
      end

      end
  end
end
