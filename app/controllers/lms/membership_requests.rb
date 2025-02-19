# frozen_string_literal: true

module Lms
  class MembershipRequests < Lms::Base
    helpers Lms::QueryParams::MembershipParams
    helpers Lms::Helpers::LibraryCardDeliveryHelper
    helpers do
      def member_info(user)
        member = user.member
        present_address = user.saved_addresses.present.first
        permanent_address = user.saved_addresses.permanent.first
        {
          full_name: user.full_name,
          phone: user.phone,
          email: user.email,
          dob: user.dob,
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
      route_setting :authentication, optional: true

      params do
        use :pagination, max_per_page: 25
      end

      get do
        memberships = MembershipRequest.all.order(id: :desc)
        Lms::Entities::MembershipRequests.represent(paginate(memberships))
      end

      desc 'membership upgrade request'
      params do
        use :membership_upgrade_params
      end

      post 'upgrade' do
        keys_to_exclude = %i[nid_front_image_file nid_back_image_file birth_certificate_image_file
                             student_id_image_file verification_certificate_image_file]
        params_except_images = params.except(*keys_to_exclude)
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  staff, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        user = User.active.find_by(phone: params[:phone])
        unless user.present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'User not found' },
                                  staff, false)
          error!('User not found', HTTP_CODE[:NOT_FOUND])
        end
        member = user.member
        unless member.present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Member not found' },
                                  staff, false)
          error!('Member not found', HTTP_CODE[:NOT_FOUND])
        end
        request_detail_attributes = params.except(:staff_id, :phone, :is_self_recipient)
        validate_params = MembershipManagement::ManageMembershipRequest.call(user:,
                                                                             request_params: request_detail_attributes,
                                                                             request_type: 'upgrade')

        error!(validate_params.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE]) unless validate_params.success?

        if params[:card_delivery_type] == 'home_delivery'
          request_detail_attributes.merge!(validate_home_delivery_address(params_except_images, member, staff))
        end
        membership = user.membership_requests.build(created_by: staff,
                                                    updated_by: staff,
                                                    request_type: 'upgrade',
                                                    status: 'payment_pending',
                                                    request_detail_attributes: request_detail_attributes
                                                                                 .merge!(member_info(user)))
        if membership.save!
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:CREATED] },
                                  staff, true)
          Lms::Entities::Patrons.represent(user)
        end
      end

      route_param :id do
        desc 'Membership Request Details'
        get do
          membership = MembershipRequest.find_by(id: params[:id])
          unless membership.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Not Found' },
                                    @current_library, false)
            error!('Not Found', HTTP_CODE[:NOT_FOUND])
          end
          Lms::Entities::MembershipRequests.represent(membership)
        end

        desc 'Membership Request Accept Reject'
        params do
          requires :status, type: String, values: %w[payment_pending rejected correction_required], allow_blank: false
          optional :notes, type: [String], allow_blank: false
        end

        post 'accept_reject' do
          membership = MembershipRequest.find_by(id: params[:id])
          unless membership.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Not Found' },
                                    @current_library, false)
            error!('Not Found', HTTP_CODE[:NOT_FOUND])
          end
          if membership.payment_pending? || membership.rejected?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: 'Not a pending request' },
                                    @current_library, false)
            error!('Not a pending request', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          member = membership.user&.member
          if member.present? && member.is_active && member.expire_date >= DateTime.now && membership.request_type != 'upgrade'
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'You have active membership.' },
                                    @current_library, false)
            error!('You have active membership.', HTTP_CODE[:BAD_REQUEST])
          end
          if params[:status] == 'rejected'
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Specify reject reason.' },
                                    @current_library, false)
            error!('Specify reject reason.', HTTP_CODE[:BAD_REQUEST]) unless params[:notes].present?
          end
          if params[:status] == 'correction_required' && !params[:notes].present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Specify which items to correct.' },
                                    @current_library, false)
            error!('Specify which items to correct.', HTTP_CODE[:BAD_REQUEST])
          end
          if membership.update!(declared(params).merge!(updated_by: @current_library))
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    @current_library, true)
            Lms::Entities::MembershipRequests.represent(membership)
          end
        end

        desc 'Update membership request info'
        params do
          use :membership_update_params
        end

        put :update do
          keys_to_include = %i[profile_image_file nid_front_image_file nid_back_image_file birth_certificate_image_file
                               student_id_image_file verification_certificate_image_file]
          params_except_images = { staff_id: params[:staff_id], member_id: params[:member_id],
                                   request_detail_attributes: params[:request_detail_attributes].slice(*keys_to_include) }
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    staff, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          membership_request = MembershipRequest.find_by(id: params[:id])
          unless membership_request.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Membership request not found' },
                                    staff, false)
            error!('Membership request not found', HTTP_CODE[:NOT_FOUND])
          end
          unless membership_request.correction_required?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'This request not in editable state' },
                                    staff, false)
            error!('This request not in editable state.', HTTP_CODE[:BAD_REQUEST])
          end
          unless (params[:request_detail_attributes][:nid_front_image_file].present? && params[:request_detail_attributes][:nid_back_image_file].present?) || params[:request_detail_attributes][:birth_certificate_image_file].present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: 'NID/Birth certificate is required' },
                                    staff, false)
            error!('NID/Birth certificate is required', HTTP_CODE[:BAD_REQUEST])
          end
          membership_request.request_detail.update!(params[:request_detail_attributes])
          membership_request.update!(status: 'correction_submitted', updated_by: staff)
          Lms::Entities::MembershipRequests.represent(membership_request)
        end
      end
    end
  end
end
