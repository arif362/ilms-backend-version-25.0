# frozen_string_literal: true

module PublicLibrary
  class MembershipRequests < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::MembershipParams
    helpers do
      def request_details_attributes(current_user)
        member = current_user.member
        present_address = @current_user.saved_addresses.present.first
        permanent_address = @current_user.saved_addresses.permanent.first
        {
          full_name: @current_user&.full_name,
          phone: @current_user&.phone,
          email: @current_user&.email,
          dob: @current_user&.dob,
          gender: member&.gender,
          father_Name: member&.father_Name,
          mother_name: member&.mother_name,
          library_id: member&.library_id,
          present_address: present_address&.address,
          present_division_id: present_address&.division_id,
          present_district_id: present_address&.district_id,
          present_thana_id: present_address&.thana_id,
          permanent_address: permanent_address&.address,
          permanent_division_id: permanent_address&.division_id,
          permanent_district_id: permanent_address&.district_id,
          permanent_thana_id: permanent_address&.thana_id
        }
      end


    end

    resources :membership_requests do
      desc 'Membership Requests'
      params do
        use :pagination, max_per_page: 25
      end

      get do
        memberships = @current_user.membership_requests.order(id: :desc)
        PublicLibrary::Entities::MembershipRequests.represent(paginate(memberships))
      end

      desc 'Submit a new membership request'
      params do
        use :membership_create_params
      end

      post do
        validate_params = MembershipManagement::ManageMembershipRequest.call(user: @current_user,
                                                                             request_params: params[:request_detail_attributes],
                                                                             request_type: 'initial')
        error!(validate_params.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE]) unless validate_params.success?
        membership = @current_user.membership_requests.build(declared(params).merge!(created_by: @current_user,
                                                                                     request_type: 'initial'))
        ActiveRecord::Base.transaction do
          %w[present permanent].each do |type|
            SavedAddress.add_address(@current_user, type.titleize.to_s, params[:request_detail_attributes]["#{type}_address".to_sym],
                                     params[:request_detail_attributes]["#{type}_division_id".to_sym], params[:request_detail_attributes]["#{type}_district_id".to_sym],
                                     params[:request_detail_attributes]["#{type}_thana_id".to_sym], @current_user.full_name, @current_user.phone,
                                     params[:request_detail_attributes]["#{type}_delivery_area_id".to_sym], params[:request_detail_attributes]["#{type}_delivery_area".to_sym], type.to_s.to_sym)
          end
          raise ActiveRecord::Rollback unless membership.save!
        end

        Lms::CreateUser.call(request_detail: membership.request_detail,
                             user_identity: { user_type: 'member',
                                              attachments: { profile_photo: params[:request_detail_attributes][:profile_image_file].present? ? params[:request_detail_attributes][:profile_image_file][:tempfile] : "",
                                                             student_id_image_file: params[:request_detail_attributes][:student_id_image_file].present? ? params[:request_detail_attributes][:student_id_image_file][:tempfile] : "" ,
                                                             nid_front_image_file: params[:request_detail_attributes][:nid_front_image_file].present? ? params[:request_detail_attributes][:nid_front_image_file][:tempfile] : "" ,
                                                             nid_back_image_file: params[:request_detail_attributes][:nid_back_image_file].present? ? params[:request_detail_attributes][:nid_back_image_file][:tempfile] : "",
                                                             birth_certificate_image_file: params[:request_detail_attributes][:birth_certificate_image_file].present? ? params[:request_detail_attributes][:birth_certificate_image_file][:tempfile] : ""} },
                             user_able: @current_staff)
        PublicLibrary::Entities::MembershipRequests.represent(membership)
      end

      desc 'membership upgrade request'
      params do
        use :membership_upgrade_params
      end

      post 'upgrade' do
        validate_params = MembershipManagement::ManageMembershipRequest.call(user: @current_user,
                                                                             request_params: params[:request_detail_attributes],
                                                                             request_type: 'upgrade')

        error!(validate_params.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE]) unless validate_params.success?
        member_params = request_details_attributes(@current_user)
        params[:request_detail_attributes].merge!(member_params)
        membership = @current_user.membership_requests.build(params.merge!(created_by: @current_user,
                                                                           updated_by: @current_user,
                                                                           request_type: 'upgrade'))
        if membership.save!
          Lms::UpgradeMemberJob.perform_later(
            membership.request_detail,
            { user_type: params[:request_detail_attributes][:membership_category], request_type: 'upgrade' },
            @current_user
          )

          PublicLibrary::Entities::MembershipRequests.represent(membership)
        end
      end

      desc 'Request details'
      get '/details' do
        last_membership_req = @current_user.membership_requests&.last

        error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless last_membership_req.present?

        PublicLibrary::Entities::MembershipRequests.represent(last_membership_req)
      end

      desc 'Update membership request info'
      params do
        use :membership_update_params
      end

      put :update do
        last_membership_req = @current_user.membership_requests&.last
        unless last_membership_req.correction_required?
          error!('This request not in editable state.', HTTP_CODE[:BAD_REQUEST])
        end
        request_detail = last_membership_req.request_detail
        unless (request_detail.nid_front_image.present? && request_detail.nid_back_image.present?) || request_detail.birth_certificate_image.present?
          error!('NID/Birth certificate is required', HTTP_CODE[:BAD_REQUEST])
        end

        request_detail.update!(params[:request_detail_attributes])
        last_membership_req.update!(status: 'correction_submitted', updated_by: @current_user)
        PublicLibrary::Entities::MembershipRequests.represent(last_membership_req)
      end

      route_param :id do
        desc 'return delivery charge'
        params do
          use :delivery_charge_params
        end

        get :delivery_charge do
          district = District.find_by(id: params[:district_id])
          error!('District not Found', HTTP_CODE[:NOT_FOUND]) unless district.present?

          membership_request = MembershipRequest.find_by(id: params[:id])
          error!('Membership request not Found', HTTP_CODE[:BAD_REQUEST]) unless membership_request.present?

          delivery_charge = calculate_card_delivery_charge(membership_request, district)
          { "delivery_charge": delivery_charge }
        end

        desc 'security money payment'
        params do
          use :security_money_payment_params
        end

        put '/security_money_payment' do

          membership_request = MembershipRequest.find_by(id: params[:id])
          error!('Membership Request not found', HTTP_CODE[:NOT_FOUND]) unless membership_request.present?

          unless params[:card_delivery_type] == 'home_delivery'
            return PublicLibrary::Entities::MembershipRequests.represent(membership_request)
          end

          request_detail = membership_request.request_detail
          member = Member.find_by(membership_request_id: params[:id])
          error!('You are already member', HTTP_CODE[:FORBIDDEN]) if member.present?

          validated_params = LibraryCardService::DeliveryAddressValidation.call(request_params: params, membership_request:)
          error!(validated_params.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE]) unless validated_params.success?
          request_detail.update!(declared(params, include_missing: false).except(:membership_request_id))

          PublicLibrary::Entities::MembershipRequests.represent(membership_request)
        end
      end
    end
  end
end
