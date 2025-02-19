# frozen_string_literal: true

module Admin
  class Staffs < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::StaffParams
    resources :staffs do
      desc 'Staff List'
      params do
        use :pagination, per_page: 25
        requires :staff_type, type: String, values: %w[admin library]
        optional :name, type: String, allow_blank: false
        optional :library_id, type: Integer, allow_blank: false
        optional :phone, type: String, allow_blank: false
      end

      get do
        staffs = Staff.except_system_admin.where(staff_type: params[:staff_type])
        authorize staffs, :read?, policy_class: policy_class(params[:staff_type])
        staffs = staffs.where('name LIKE ?', "%#{params[:name]}%") if params[:name].present?
        staffs = staffs.where('phone LIKE ?', "%#{params[:phone]}%") if params[:phone].present?
        staffs = staffs.where(library_id: params[:library_id]) if params[:library_id].present?
        Admin::Entities::Staffs.represent(paginate(staffs&.order(id: :desc)))
      end

      desc 'Create Staff'
      params do
        use :staff_create_params
      end

      post do
        designation = Designation.find_by(id: params[:designation_id])
        error!('Designation not found', HTTP_CODE[:NOT_FOUND]) unless designation.present?
        error!('Password cannot be blank', HTTP_CODE[:NOT_ACCEPTABLE]) if params[:password].blank?
        if params[:password] != params[:password_confirmation]
          error!('Password didn\'t match', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        error!('Email already exists', HTTP_CODE[:NOT_ACCEPTABLE]) unless Staff.find_by(email: params[:email]).blank?
        unless Staff.find_by(phone: params[:phone]).blank?
          error!('Phone number already exists', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        if params[:staff_type] == 'library' && params[:library_id].blank?
          error!('Library must be present', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        staff = Staff.new(declared(params).merge!(created_by_id: @current_staff.id))
        authorize staff, :create?, policy_class: policy_class(params[:staff_type])
        if staff.save!
          lib_ip_of_staff = staff.library&.ip_address
          lib_ip_of_staff&.slice!(-5, 5)
          login_base_url = staff.admin? ? 'http://elibrary-admin.dpl.gov.bd/login' : "#{lib_ip_of_staff}/login"
          StaffMailer.send_mail_to_staff(params[:email], params[:password], login_base_url).deliver_later
          if staff.library?
            staff = staff.reload
            Lms::CreateUser.call(request_detail: staff,
                                 user_identity: { user_type: 'staff',
                                                  password: params[:password],
                                                  attachments: { profile_photo: params[:avatar_image].present? ? params[:avatar_image][:tempfile] : "",
                                                                 signature: params[:authorized_signature_image].present? ? params[:authorized_signature_image][:tempfile] : ""} },
                                 user_able: @current_staff)
          end
          Admin::Entities::Staffs.represent(staff)
        end
      end

      desc 'Staff Details'
      get '/profile' do
        Admin::Entities::Staffs.represent(@current_staff)
      end

      route_param :id do
        desc 'Staff Details'
        get do
          staff = Staff.except_system_admin.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless staff.present?
          authorize staff, :read?, policy_class: policy_class(staff.staff_type)
          Admin::Entities::Staffs.represent(staff)
        end

        desc 'Staff Update'
        params do
          use :staff_update_params
        end

        put do
          staff = Staff.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless staff.present?
          authorize staff, :update?, policy_class: policy_class(staff.staff_type)

          staff.update!(declared(params).merge!(updated_by_id: @current_staff.id))
          Admin::Entities::Staffs.represent(staff)
        end

        desc 'Staff Delete'
        delete do
          staff = Staff.except_system_admin.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless staff.present?
          authorize staff, :delete?, policy_class: policy_class(staff.staff_type)

          Admin::Entities::Staffs.represent(staff) if staff.update!(is_deleted: true, updated_by_id: @current_staff.id)
        end

        desc 'Staff type change'
        params do
          use :staff_type_params
        end

        put :change_type do
          staff = Staff.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless staff.present?
          authorize staff, :type_change?, policy_class: policy_class(staff.staff_type)

          if (params[:staff_type] == 'admin') && params[:role_id].blank?
            error!('Role must be exist', HTTP_CODE[:BAD_REQUEST])
          end

          if (params[:staff_type] == 'library') && params[:library_id].blank?
            error!('Library must be exist', HTTP_CODE[:BAD_REQUEST])
          end

          staff.staff_type = params[:staff_type]
          staff.library_id = params[:staff_type] == 'library' ? params[:library_id] : nil
          staff.role_id = params[:staff_type] == 'admin' ? params[:role_id] : nil
          staff.created_by_id = @current_staff.id

          Admin::Entities::Staffs.represent(staff) if staff.save!
        end
      end
    end

    helpers do
      def policy_class(staff_type)
        case staff_type
        when 'admin'
          StaffPolicy
        when 'library'
          LibrarianPolicy
        end
      end
    end
  end
end
