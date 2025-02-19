# frozen_string_literal: true

module MembershipManagement
  class ManageMembershipRequest
    include Interactor

    delegate :user, :request_params, :request_type, to: :context

    def call
      if user.membership_requests.processing.count.positive?
        context.fail!(error: 'You have already a membership request in processing')
      end
      unless request_type.present? || MembershipRequest.request_types.include?(request_type)
        context.fail!(error: 'Invalid request type')
      end
      validate_membership
      validate_info
    end

    private

    def validate_membership
      member = user&.member
      case request_type
      when 'initial'
        context.fail!(error: 'You have active membership') if member.present? && member.is_active
      when 'upgrade'
        context.fail!(error: 'Member not found') unless member.present? && member.is_active
      end
    end

    def validate_info
      membership_category = request_params[:membership_category]
      validate_upgrade_plan(user&.member&.membership_category, membership_category) if request_type == 'upgrade'
      validate_membership_category(request_params[:membership_category])
      validate_identity_type(request_params[:membership_category])
      validate_required_plan_info if %w[student general].include?(request_params[:membership_category])
    end

    def validate_membership_category(membership_category)
      case membership_category
      when 'child'
        unless request_params[:birth_certificate_image_file].present?
          context.fail!(error: 'Birth certificate image is required')
        end
      when 'student'
        context.fail!(error: 'Student ID image is required') unless request_params[:student_id_image_file].present?
      end
      validate_nid_or_birth_image if %w[student general].include?(membership_category)
      remove_extra_image_file
    end

    def validate_nid_or_birth_image
      verification_image = (request_params[:nid_front_image_file].present? &&
        request_params[:nid_back_image_file].present?) || request_params[:birth_certificate_image_file].present?
      context.fail!(error: 'NID/Birth certificate is required') unless verification_image
    end

    def validate_upgrade_plan(current_category, requested_category)
      case current_category
      when 'child'
        unless %w[student general].include?(requested_category)
          context.fail!(error: 'Can only upgrade to student or general category')
        end
      when 'student'
        context.fail!(error: 'Can only upgrade to general category') unless requested_category == 'general'
      else
        context.fail!(error: 'No upgrade plan is available for general member')
      end
    end

    def remove_extra_image_file
      if request_params[:membership_category] == 'child'
        context.fail!(error: 'Remove NID image file for child membership') if check_nid_image
      elsif request_params[:birth_certificate_image_file].present? && check_nid_image
        context.fail!(error: 'Provide either birth certificate or NID image file')
      end
      check_student_image if %w[child general].include?(request_params[:membership_category])
    end

    def check_nid_image
      return true if request_params[:nid_front_image_file].present? || request_params[:nid_back_image_file].present?

      false
    end

    def check_student_image
      return unless request_params[:student_id_image_file].present?

      context.fail!(error: 'Please remove student id image')
    end

    def validate_identity_type(membership_category)
      valid_identity_types = { child: ['birth_certificate'], student: %w[nid birth_certificate],
                               general: %w[nid birth_certificate] }
      return if valid_identity_types[membership_category.to_sym].include?(request_params[:identity_type])

      context.fail!(error: 'Invalid identity type')
    end

    def validate_required_plan_info
      fields = { 'student': %w[student_class student_section student_id institute_name institute_address],
                 'general': %w[profession institute_name institute_address] }
      required_fields = fields[:"#{request_params[:membership_category]}"]
      return if required_fields.all? { |field| request_params.key?(field) }

      context.fail!(error: "Please provide all these fields: #{fields[:"#{request_params[:membership_category]}"].join(', ')}")
    end
  end
end
