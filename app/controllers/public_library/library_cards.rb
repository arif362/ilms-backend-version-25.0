# frozen_string_literal: true

module PublicLibrary
  class LibraryCards < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::LibraryCardParams

    resources :library_cards do
      desc 'Card requests'
      params do
        use :pagination, max_per_page: 25
      end
      get do
        error!('Need Membership', HTTP_CODE[:NOT_ACCEPTABLE]) unless @current_user.member.present?

        card_requests = @current_user.member.library_cards.order(id: :desc)
        PublicLibrary::Entities::LibraryCards.represent(paginate(card_requests))
      end

      desc 'Apply for card (lost/damage/renew)'
      params do
        use :apply_card_params
      end
      post :apply do
        error!('Need Membership', HTTP_CODE[:NOT_ACCEPTABLE]) unless @current_user.member.present?
        member = @current_user.member
        last_card = member.library_cards.order(:id).last
        error!('You have no card yet', HTTP_CODE[:NOT_ACCEPTABLE]) if last_card.nil?
        if (CardStatus.status_keys.keys - CardStatus::FINISHED_STATUSES).include?(last_card.card_status.status_key)
          error!('You have processing card request', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        if params[:delivery_type] == 'home_delivery'
          error!('Delivery address type is required', HTTP_CODE[:BAD_REQUEST]) unless params[:address_type].present?
          error!('Recipient name is required', HTTP_CODE[:BAD_REQUEST]) unless params[:recipient_name].present?
          error!('Recipient phone is required', HTTP_CODE[:BAD_REQUEST]) unless params[:recipient_phone].present?
          error!('Delivery area id is required', HTTP_CODE[:BAD_REQUEST]) unless params[:delivery_area_id].present?
          error!('Delivery area is required', HTTP_CODE[:BAD_REQUEST]) unless params[:delivery_area].present?

          if params[:address_type] == 'others'
            unless params[:delivery_address].present?
              error!('Recipient delivery address is required', HTTP_CODE[:BAD_REQUEST])
            end
            unless params[:division_id].present?
              error!('Recipient delivery division is required', HTTP_CODE[:BAD_REQUEST])
            end
            unless params[:district_id].present?
              error!('Recipient delivery district is required', HTTP_CODE[:BAD_REQUEST])
            end
            unless params[:thana_id].present?
              error!('Recipient delivery thana is required', HTTP_CODE[:BAD_REQUEST])
              thana = Thana.find_by(id: params[:thana_id])

              error!('Thana not found', HTTP_CODE[:NOT_FOUND]) unless thana.present?

              params[:issued_library_id] = thana&.library.present? ? thana&.library : thana.district.library_from_district(thana)
            end
          elsif params[:address_type] == 'permanent'
            params[:delivery_address] = member.permanent_address
            params[:division_id] = member.permanent_division_id
            params[:district_id] = member.permanent_district_id
            params[:thana_id] = member.permanent_thana_id
            params[:issued_library_id] =
              member.permanent_thana&.library.present? ? member.permanent_thana&.library : member.permanent_thana.district.library_from_district(member.permanent_thana)
          else
            params[:delivery_address] = member.present_address
            params[:division_id] = member.present_division_id
            params[:district_id] = member.present_district_id
            params[:thana_id] = member.present_thana_id
            params[:issued_library_id] =
              member.present_thana&.library.present? ? member.present_thana&.library : member.present_thana.district.library_from_district(member.present_thana)
          end
        end
        if params[:apply_reason] == 'lost' && !params[:gd_image_file].present?
          error!('Copy of GD is required', HTTP_CODE[:BAD_REQUEST])
        end
        if params[:apply_reason] == 'damage' && !params[:card_image_file].present?
          error!('Picture of damaged card is required', HTTP_CODE[:BAD_REQUEST])
        end
        if params[:apply_reason] == 'renew' && !params[:card_image_file].present?
          error!('Picture of old card is required', HTTP_CODE[:BAD_REQUEST])
        end

        last_card.is_active = false
        case params[:apply_reason]
        when 'lost'
          last_card.is_lost = true
          last_card.gd_image_file = params[:gd_image_file]
        when 'damage'
          last_card.is_damaged = true
          last_card.damaged_card_image_file = params[:card_image_file]
        when 'renew'
          last_card.is_expired = true
          last_card.damaged_card_image_file = params[:card_image_file]
        end
        last_card.updated_by = @current_user
        last_card.save!

        new_card = member.library_cards.create!(
          name: member.user&.full_name,
          issued_library_id: params[:issued_library_id],
          membership_category: member.membership_category,
          card_status_id: CardStatus.find_by(status_key: CardStatus.status_keys[:pending]).id,
          pay_type: params[:pay_type],
          delivery_type: params[:delivery_type],
          address_type: params[:address_type],
          recipient_name: params[:recipient_name],
          delivery_area: params[:delivery_area],
          delivery_area_id: params[:delivery_area_id],
          recipient_phone: params[:recipient_phone],
          delivery_address: params[:delivery_address],
          division_id: params[:division_id],
          district_id: params[:district_id],
          thana_id: params[:thana_id],
          reference_card_id: last_card.id,
          is_active: false,
          issue_date: Time.current,
          expire_date: Time.current.next_year(100)
        )

        if params[:save_address].present? && params[:address_type] == 'others'
          error!('Address title/name is required', HTTP_CODE[:BAD_REQUEST]) unless params[:address_name].present?

          SavedAddress.add_address(@current_user, params[:address_name], params[:address], params[:division_id],
                                   params[:district_id], params[:thana_id], params[:recipient_name], params[:recipient_phone], params[:delivery_area_id], params[:delivery_area] )
        end
        PublicLibrary::Entities::LibraryCardDetails.represent(new_card)
      end

      desc 'Card Details'
      get 'details' do
        error!('Need Membership', HTTP_CODE[:NOT_ACCEPTABLE]) unless @current_user.member.present?
        member = @current_user.member
        card = member.library_cards.where(is_active: true).last
        error!('Not Found', HTTP_CODE[:NOT_FOUND]) if card.nil?

        PublicLibrary::Entities::LibraryCardDetails.represent(card)
      end
    end
  end
end