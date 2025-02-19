# frozen_string_literal: true

module Admin
  class Members < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::MemberParams
    resources :members do
      desc 'Members List'
      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String
        optional :library_code, type: String
        optional :membership_category, type: String, values: %w[general student child]
        optional :gender, type: String, values: %w[male female other]
      end

      get do
        members = if params[:search_term].present?
                    if params[:search_term].starts_with?('M', 'm')
                      Member.where(id: params[:search_term][2..].to_i)
                    else
                      Member.search_unique_id_or_phone(params[:search_term])
                    end
                  else
                    Member.all
                  end
        members = members.where(gender: params[:gender]) if params[:gender].present?
        members = members.where(membership_category: params[:membership_category]) if params[:membership_category].present?
        if params[:library_code].present?
          library = Library.find_by(code: params[:library_code])
          members = members.where(library_id: library&.id)
        end
        authorize members, :read?
        Admin::Entities::MemberList.represent(paginate(members.order(id: :desc)))

      rescue Pundit::NotAuthorizedError => e
        Rails.logger.error " NO ACCESS  #{e.message}"
        error!('No access', HTTP_CODE[:FORBIDDEN])

      rescue StandardError => e
        Rails.logger.info("Failed to fetch member list - #{e.full_message}")
        error!(failure_response('Failed to fetch member list'))
      end

      route_param :id do
        desc 'Member Details'
        get do
          member = Member.find_by(id: params[:id])
          error!('Member not found', HTTP_CODE[:NOT_FOUND]) unless member.present?
          authorize member, :read?
          Admin::Entities::MemberDetails.represent(member)
        end

        desc 'Member Update'
        params do
          use :member_update_params
        end

        put do
          member = Member.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless member.present?
          authorize member, :update?
          if params[:identity_type].present? && params[:identity_type] == 'nid'
            error!('Failed to update due to - nid missing', HTTP_CODE[:NO_CONTENT]) if !params[:identity_front_image].present? || !params[:identity_back_image].present?
          end
          if ["birth_certificate", "student_id"].include?(params[:identity_type])
            error!("Failed to update due to - #{params[:identity_type]} missing", HTTP_CODE[:NO_CONTENT]) if !params[:identity_front_image].present?
          end
          member.update!(declared(params).merge!(updated_by_id: @current_staff.id))
          Admin::Entities::MemberList.represent(member)
        end
      end
    end
  end
end
