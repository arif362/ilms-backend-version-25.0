# frozen_string_literal: true

module Lms
  class LibraryCards < Lms::Base
    helpers Lms::QueryParams::LibraryCardParams

    helpers do
      def validate_delivered_status(params, card, staff)
        incoming_flag = false
        outgoing_flag = false
        if params[:status] == 'delivered' && @current_library == card.printing_library
          if card.delivery_type != 'home_delivery'
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: 'Invalid status delivered for pick up delivery type' },
                                    staff, false)
            error!('Invalid status delivered for pick up delivery type', HTTP_CODE[:BAD_REQUEST])
          else
            outgoing_flag = true
          end
        end
        incoming_flag = true if params[:status] == 'delivered_to_library' && @current_library == card.issued_library
        Rails.logger.info "-------delivered---------#{outgoing_flag}-----#{incoming_flag}-------"
        { incoming_flag:, outgoing_flag: }
      end

      def validate_card_status(params, card, staff)
        if card.card_status == CardStatus.finished_statuses
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST],
                                    error: 'Card already delivered/cancelled/rejected' },
                                  staff, false)
          error!('Card already delivered/cancelled/rejected', HTTP_CODE[:BAD_REQUEST])
        end
        status = CardStatus.get_status(params[:status])
        if status.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Card status not found' },
                                  staff, false)
          error!('Card status not found', HTTP_CODE[:NOT_FOUND])
        end
        if card.card_status.status_key == params[:status]
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST],
                                    error: "The #{params[:status]} status already exist" },
                                  staff, false)
          error!("The #{params[:status]} status has already exist", HTTP_CODE[:BAD_REQUEST])
        end
        status
      end

      def validate_printing_library(params, staff)
        if params[:printing_library_id].blank?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Printing library is required' },
                                  staff, false)
          error!('Printing library is required', HTTP_CODE[:BAD_REQUEST])
        end

        printing_library = Library.find_by(id: params[:printing_library_id])
        if printing_library.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Printing library not found' },
                                  staff, false)
          error!('Printing library not found', HTTP_CODE[:NOT_FOUND])
        end
      end

      def send_print_request(params, staff)
        # check printing library is present and valid
        validate_printing_library(params, staff)
        true
      end

      def allowed_status_libraries(params, card, staff)
        incoming_flag = false
        outgoing_flag = false
        diff_pl_statuses = %w[printed ready_for_pickup collected_by_3pl cancelled delivered on_hold
                              rejected accepted]
        diff_il_statuses = %w[delivered delivered_to_library]
        if @current_library == card.printing_library
          unless diff_pl_statuses.include?(params[:status])
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: "Invalid status: #{params[:status]} for printing library" },
                                    staff, false)
            error!("Invalid status: #{params[:status]} for printing library", HTTP_CODE[:BAD_REQUEST])
          end
          outgoing_flag = true
        else
          unless diff_il_statuses.include?(params[:status])
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: "Invalid status: #{params[:status]} for issued library" },
                                    staff, false)
            error!("Invalid status: #{params[:status]} for issued library", HTTP_CODE[:BAD_REQUEST])
          end
          incoming_flag = true
        end
        Rails.logger.info "-------allowed---------#{outgoing_flag}-----#{incoming_flag}-------"
        { incoming_flag:, outgoing_flag: }
      end
    end
    resources :library_cards do
      desc 'Card list'
      params do
        use :pagination, per_page: 25
        optional :status_id, type: Integer, allow_blank: false
        optional :delivery_type, type: String, values: LibraryCard.delivery_types.keys, allow_blank: false
        optional :member_id, type: Integer, allow_blank: false
      end
      get do
        cards = @current_library.library_cards.includes(:member)
        cards = cards.where(card_status_id: params[:status_id]) if params[:status_id].present?
        cards = cards.where(delivery_type: params[:delivery_type]) if params[:delivery_type].present?
        cards = cards.where(member_id: params[:member_id]) if params[:member_id].present?
        cards = cards.order(id: :desc)
        Lms::Entities::LibraryCards.represent(paginate(cards))
      end

      desc 'Card status list for dropdown'
      route_setting :authentication, optional: true
      get :statuses do
        Lms::Entities::CardStatus.represent(CardStatus.all.order(lms_status: :desc))
      end

      desc 'Apply for card (lost/damage/renew)'
      params do
        use :apply_card_params
      end

      post :apply do
        params_except_images = params.except(:card_image_file, :gd_image_file)
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        member = Member.find_by(id: params[:member_id])
        unless member.present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Member not found' },
                                  staff, false)
          error!('Member not found', HTTP_CODE[:NOT_FOUND])
        end
        last_card = member.library_cards.order(:id).last
        if last_card.nil?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'You have no card yet' },
                                  staff, false)
          error!('You have no card yet', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        if (CardStatus.status_keys.keys - CardStatus::FINISHED_STATUSES).include?(last_card.card_status.status_key)
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'You have processing card request' },
                                  staff, false)
          error!('You have processing card request', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        if params[:delivery_type] == 'home_delivery'
          unless params[:address_type].present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Delivery address type is required' },
                                    staff, false)
            error!('Delivery address type is required', HTTP_CODE[:BAD_REQUEST])
          end
          if params[:is_self_recipient] == false && params[:recipient_name].blank?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Recipient name is required' },
                                    staff, false)
            error!('Recipient name is required', HTTP_CODE[:BAD_REQUEST])
          end
          if params[:is_self_recipient] == false && params[:recipient_phone].blank?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Recipient phone is required' },
                                    staff, false)
            error!('Recipient phone is required', HTTP_CODE[:BAD_REQUEST])
          end

          if params[:address_type] == 'others'
            unless params[:delivery_address].present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Recipient delivery address is required' },
                                      staff, false)
              error!('Recipient delivery address is required', HTTP_CODE[:BAD_REQUEST])
            end
            unless params[:division_id].present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Recipient delivery division is required' },
                                      staff, false)
              error!('Recipient delivery division is required', HTTP_CODE[:BAD_REQUEST])
            end
            unless params[:district_id].present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Recipient delivery district is required' },
                                      staff, false)
              error!('Recipient delivery district is required', HTTP_CODE[:BAD_REQUEST])
            end
            unless params[:thana_id].present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Recipient delivery thana is required' },
                                      staff, false)
              error!('Recipient delivery thana is required', HTTP_CODE[:BAD_REQUEST])
              thana = Thana.find_by(id: params[:thana_id])

              unless thana.present?
                LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: 'Thana not found' },
                                        staff, false)
                error!('Thana not found', HTTP_CODE[:NOT_FOUND])
              end

              params[:issued_library_id] = thana&.library.present? ? thana&.library : thana.district.library_from_district(thana)
            end

            unless params[:delivery_area_id].present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST], error: 'delivery_area_id is required' },
                                      staff, false)
              error!('delivery_area_id district is required', HTTP_CODE[:BAD_REQUEST])
            end

            unless params[:delivery_area].present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST], error: 'delivery_area is required' },
                                      staff, false)
              error!('delivery_area district is required', HTTP_CODE[:BAD_REQUEST])
            end

          elsif params[:address_type] == 'permanent'
            params[:delivery_address] = member.permanent_address
            params[:division_id] = member.permanent_division_id
            params[:district_id] = member.permanent_district_id
            params[:thana_id] = member.permanent_thana_id
            params[:delivery_area_id] = member.user.saved_addresses.permanent.last.delivery_area_id
            params[:delivery_area] = member.user.saved_addresses.permanent.last.delivery_area
            params[:issued_library_id] =
              member.permanent_thana&.library.present? ? member.permanent_thana&.library : member.permanent_thana.district.library_from_district(member.permanent_thana)
          else
            params[:delivery_address] = member.present_address
            params[:division_id] = member.present_division_id
            params[:district_id] = member.present_district_id
            params[:thana_id] = member.present_thana_id
            params[:delivery_area_id] = member.user.saved_addresses.present.last.delivery_area_id
            params[:delivery_area] = member.user.saved_addresses.present.last.delivery_area
            params[:issued_library_id] =
              member.present_thana&.library.present? ? member.present_thana&.library : member.present_thana.district.library_from_district(member.present_thana)
          end
        end
        if params[:apply_reason] == 'lost' && !params[:gd_image_file].present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Copy of GD is required' },
                                  staff, false)
          error!('Copy of GD is required', HTTP_CODE[:BAD_REQUEST])
        end
        if params[:apply_reason] == 'damage' && !params[:card_image_file].present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Picture of damaged card is required' },
                                  staff, false)
          error!('Picture of damaged card is required', HTTP_CODE[:BAD_REQUEST])
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
        last_card.updated_by = staff
        last_card.save!

        new_card = member.library_cards.create!(
          name: member.user&.full_name,
          issued_library_id: @current_library.id,
          membership_category: member.membership_category,
          card_status_id: CardStatus.find_by(status_key: CardStatus.status_keys[:pending]).id,
          pay_type: params[:pay_type],
          delivery_type: params[:delivery_type],
          address_type: params[:address_type],
          recipient_name: params[:is_self_recipient] ? member.user.full_name : params[:recipient_name],
          recipient_phone: params[:is_self_recipient] ? member.user.phone : params[:recipient_phone],
          delivery_address: params[:delivery_address],
          division_id: params[:division_id],
          district_id: params[:district_id],
          thana_id: params[:thana_id],
          reference_card_id: last_card.id,
          is_active: true,
          issue_date: Time.current,
          expire_date: Time.current.next_year(100)
        )

        if params[:save_address].present? && params[:address_type] == 'others'
          unless params[:address_name].present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Address title/name is required' },
                                    @current_library, false)
            error!('Address title/name is required', HTTP_CODE[:BAD_REQUEST])
          end

          SavedAddress.add_address(@current_user, params[:address_name], params[:address], params[:division_id],
                                   params[:district_id], params[:thana_id], params[:recipient_name], params[:recipient_phone], params[:delivery_area_id], params[:delivery_area])
        end
        PublicLibrary::Entities::LibraryCardDetails.represent(new_card)
      end

      route_param :id do
        desc 'Card details'
        get do
          card = @current_library.library_cards.find_by(id: params[:id])
          if card.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Not Found' },
                                    @current_library, false)
            error!('Not Found', HTTP_CODE[:NOT_FOUND])
          end
          Lms::Entities::LibraryCards.represent(card)
        end

        desc 'Change Status'
        params do
          requires :staff_id, type: Integer
          requires :status, type: String, values: CardStatus.status_keys.keys
          optional :printing_library_id, type: Integer
        end
        put do
          lms_flag = { outgoing_flag: false, incoming_flag: false, card_print_flag: false }
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          card = LibraryCard.find_by(id: params[:id])
          if card.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Card not found' },
                                    staff, false)
            error!('Card not found', HTTP_CODE[:NOT_FOUND])
          end
          # check for only printing and issued library
          unless @current_library == card.printing_library || @current_library == card.issued_library
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:UNAUTHORIZED],
                                      error: 'Only issued / printing library can update card status' },
                                    staff, false)
            error!('Only issued / printing library can update card status', HTTP_CODE[:UNAUTHORIZED])
          end
          status = validate_card_status(params, card, staff)
          # check whether new status can be applied
          unless card.validate_status_update(params[:status])
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: "#{card.card_status.status_key} can't be updated to  #{status.status_key}" },
                                    staff, false)
            error!("#{card.card_status.status_key} can't be updated to  #{status.status_key}", HTTP_CODE[:BAD_REQUEST])
          end

          if status.waiting_for_print?
            lms_flag[:card_print_flag] = send_print_request(params, staff)
          elsif status.delivered_to_library?
            if @current_library == card.issued_library && card.issued_library != card.printing_library
              lms_flag[:incoming_flag] = true
            else
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST],
                                        error: "Invalid status: #{params[:status]}" },
                                      staff, false)
              error!("Invalid status: #{params[:status]}", HTTP_CODE[:BAD_REQUEST])
            end
          elsif @current_library == card.issued_library
            issued_library_statuses = %w[waiting_for_print accepted printed ready_for_pickup collected_by_3pl delivered
                                         on_hold cancelled rejected]
            unless issued_library_statuses.include?(params[:status])
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST],
                                        error: "Invalid status: #{params[:status]} for issued library" },
                                      staff, false)
              error!("Invalid status: #{params[:status]} for issued library", HTTP_CODE[:BAD_REQUEST])
            end
            card.printing_library_id = @current_library.id if status.accepted?
            lms_flag[:incoming_flag] = true if status.delivered?
          else
            lms_flag = if %w[delivered delivered_to_library].include?(params[:status])
                         validate_delivered_status(params, card, staff)
                       else
                         allowed_status_libraries(params, card, staff)
                       end
            Rails.logger.info "----------------#{lms_flag}------------"
          end
          card.card_status_id = status.id
          card.printing_library_id = params[:printing_library_id] if params[:printing_library_id]
          card.save!
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          if lms_flag[:outgoing_flag]
            Lms::CardPrintManagement::OutgoingStatusUpdateJob.perform_later(card, params[:status], staff)
          elsif lms_flag[:incoming_flag]
            Lms::CardPrintManagement::IncomingStatusUpdateJob.perform_later(card, params[:status], staff)
          elsif lms_flag[:card_print_flag]
            Lms::CardPrintManagement::CreateCardPrintJob.perform_later(card, staff)
          end
          Lms::Entities::LibraryCards.represent(card)
        end

        desc 'Update smart card'
        params do
          requires :smart_card_number, type: String, allow_blank: false
          requires :staff_id, type: Integer, allow_blank: false
        end

        patch do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          card = LibraryCard.find_by(id: params[:id])
          if card.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Card not found' },
                                    staff, false)
            error!('Card not found', HTTP_CODE[:NOT_FOUND])
          end
          # check for only printing and issued library
          unless @current_library == card.printing_library
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:UNAUTHORIZED],
                                      error: 'Only issued / printing library can update card status' },
                                    staff, false)
            error!('Only issued / printing library can update card status', HTTP_CODE[:UNAUTHORIZED])
          end
          card.update!(smart_card_number: params[:smart_card_number])
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK], error: '' },
                                  staff, true)
          if @current_library.id != card.issued_library_id
            Lms::CardPrintManagement::SmartNumberUpdateJob.perform_later(card, staff)
          end
          Lms::Entities::LibraryCards.represent(card)
        end
      end
    end
  end
end
