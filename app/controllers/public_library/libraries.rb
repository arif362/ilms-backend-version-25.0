# frozen_string_literal: true

module PublicLibrary
  class Libraries < PublicLibrary::Base
    resources :libraries do

      desc 'Get all libraries for dropdown.'
      route_setting :authentication, optional: true
      get :dropdown do
        libraries = Library.active.order(id: :desc)
        PublicLibrary::Entities::LibraryDropdown.represent(libraries, locale: @locale)
      end

      desc 'Get all services'
      route_setting :authentication, optional: true
      get :services do
        services = LibraryEntryLog::SERVICE_NAMES.map { |service| { 'name' => service } }
        present services
      end

      desc 'Libraries list'
      params do
        use :pagination, per_page: 25
        optional :name, type: String
        optional :district_id, type: Integer
      end
      route_setting :authentication, optional: true
      get do
        libraries = Library.all
        if params[:name].present?
          libraries = libraries.where('lower(name) LIKE :search_name or lower(bn_name) LIKE :search_name',
                                      search_name: "%#{params[:name].downcase}%")
        end
        libraries = libraries.where(district_id: params[:district_id]) if params[:district_id].present?

        PublicLibrary::Entities::LibraryList.represent(paginate(libraries.order(name: :asc)),
                                                       locale: @locale)
      end

      route_param :code do
        desc 'Library details'
        route_setting :authentication, optional: true
        get do
          library = Library.find_by(code: params[:code])
          error!('Library not found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          PublicLibrary::Entities::LibraryDetails.represent(library, locale: @locale, request_source: @request_source)
        end

        desc 'Batch biblio available check'
        params do
          requires :biblio_ids, type: Array[String], allow_blank: false
        end
        route_setting :authentication, optional: true
        get :biblios_availability do
          library = Library.find_by(code: params[:code])
          error!('Library not Found', HTTP_CODE[:NOT_FOUND]) unless library.present?

          biblios = []
          params[:biblio_ids].each do |id|
            biblio = Biblio.find_by(id:)
            error!("Biblio not found for id : #{id}", HTTP_CODE[:NOT_FOUND]) unless biblio.present?
            biblio_libraries = library.biblio_libraries.where(biblio_id: biblio.id, available_quantity: 1...)

            available_libraries = Library.joins(:biblio_libraries)
                               .where('biblio_libraries.biblio_id = ? and biblio_libraries.available_quantity > 0', biblio.id).distinct

            biblios << if biblio_libraries.present?
                         { is_available: true, biblio: biblio.as_json(only: %i[id title]) }
                       else
                         { is_available: false, biblio: biblio.as_json(only: %i[id title]),
                           available_libraries: available_libraries.as_json(only: %i[id name code]) }
                       end
          end
          biblios
        end


        desc 'Delivery charge for cart items based on recipient library '
        params do
          requires :biblio_ids, type: Array[Integer], allow_blank: false
        end
        route_setting :authentication, optional: true
        get :cart_items_delivery_charge do

          library = Library.find_by(code: params[:code])
          error!('Library not Found', HTTP_CODE[:NOT_FOUND]) unless library.present?

          delivery_charge = 0
          books_at_all_libraries = BiblioLibrary.where(biblio_id: params[:biblio_ids], available_quantity: 1...)
          delivery_charge = 0 if books_at_all_libraries.blank?

          books_at_selected_library = library.biblio_libraries.where(biblio_id: params[:biblio_ids],
                                                                     available_quantity: 1...)
          books_without_selected_libraries = books_at_all_libraries - books_at_selected_library

          if books_at_selected_library.present?
            if books_at_selected_library.map(&:biblio_id).compact.uniq.sort == params[:biblio_ids].sort
              delivery_charge += ENV['SHIPPING_CHARGE_SAME_DISTRICT'].to_i
            elsif books_without_selected_libraries.present?
              delivery_charge += ENV['SHIPPING_CHARGE_OTHER_DISTRICT'].to_i + ENV['SHIPPING_CHARGE_SAME_DISTRICT'].to_i * books_without_selected_libraries.map(&:library_id).uniq.count
            end
          elsif books_at_all_libraries.present? && books_at_all_libraries.map(&:biblio_id).compact.uniq.sort == params[:biblio_ids].sort
            if books_at_all_libraries.map(&:library_id).uniq.count == 1
              delivery_charge += ENV['SHIPPING_CHARGE_OTHER_DISTRICT'].to_i
            elsif books_at_all_libraries.map(&:library_id).uniq.count > 1
              delivery_charge += ENV['SHIPPING_CHARGE_OTHER_DISTRICT'].to_i * books_at_all_libraries.map(&:library_id).uniq.count
            end
          end

          { delivery_charge: }
        end
      end
    end
  end
end
