# frozen_string_literal: true

module PublicLibrary
  class SavedAddresses < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::SavedAddressParams

    resources :saved_addresses do
      desc 'Addresses'
      params do
        use :pagination, max_per_page: 25
      end
      get do
        saved_addresses = @current_user.saved_addresses.order(id: :desc).includes(:division, :district, :thana)
        PublicLibrary::Entities::SavedAddresses.represent(paginate(saved_addresses))
      end

      desc 'Create Address'
      params do
        use :saved_address_create_params
      end

      post do

        division = Division.find_by(id: params[:division_id])
        error!('division not found', HTTP_CODE[:BAD_REQUEST]) unless division.present?

        district = division.districts.find_by(id: params[:district_id])
        unless district.present?
          error!("district is not found under the division of #{division.name}",
                 HTTP_CODE[:BAD_REQUEST])
        end

        thana = district.thanas.find_by(id: params[:thana_id])
        unless thana.present?
          error!("thana is not found under the district of #{district.name}",
                 HTTP_CODE[:BAD_REQUEST])
        end

        address = @current_user.saved_addresses.build(declared(params))
        PublicLibrary::Entities::SavedAddresses.represent(address) if address.save!
      end

      route_param :id do
        desc 'Update Address'
        params do
          use :saved_address_update_params
        end
        put do
          address = @current_user.saved_addresses.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) if address.nil?

          address.update!(declared(params))
          PublicLibrary::Entities::SavedAddresses.represent(address)
        end

        desc 'Delete Address'
        delete do
          saved_address = @current_user.saved_addresses.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) if saved_address.blank?
          unless saved_address.others?
            error!("#{saved_address.address_type.titleize} address not deletable, you can edit it",
                   HTTP_CODE[:NOT_FOUND])
          end

          saved_address.destroy!
          status HTTP_CODE[:OK]
        end
      end
    end
  end
end
