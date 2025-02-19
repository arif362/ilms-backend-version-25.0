# frozen_string_literal: true

module Admin
  class EditedLogs < Admin::Base
    resources :audit_logs do
      include Admin::Helpers::AuthorizationHelpers

      desc 'User Types dropdown List'

      get 'user_types' do
        Constants::USER_TYPES.sort
      end

      desc 'Auditable Types dropdown List'

      get 'auditable_types' do
        Constants::AUDITABLE_TYPES.sort
      end

      desc 'Audit log list'
      params do
        use :pagination, per_page: 25
        requires :auditable_type, type: String, allow_blank: false, values: Constants::AUDITABLE_TYPES
        optional :user_type, type: String, allow_blank: false, values: Constants::USER_TYPES
      end
      get do
        audit_logs = Audited::Audit.where.not(auditable_type: 'AuthorizationKey').where(auditable_type: params[:auditable_type])
        audit_logs = Audited::Audit.where(user_type: params[:user_type]) if params[:user_type].present?
        Admin::Entities::AuditLogDetails.represent(paginate(audit_logs.order(created_at: :desc))) if audit_logs.present?
      end

      desc 'Audit log details'
      params do
        use :pagination, per_page: 25
        requires :auditable_id, type: Integer, allow_blank: false
        requires :auditable_type, values: Constants::AUDITABLE_TYPES, allow_blank: false
      end

      get 'details' do
        audited_object = params[:auditable_type].constantize.find_by(id: params[:auditable_id])
        error!(" #{params[:auditable_type]} not found", HTTP_CODE[:NOT_FOUND]) unless audited_object.present?
        audit_logs = audited_object.audits.order(created_at: :desc)
        Admin::Entities::AuditLogDetails.represent(paginate(audit_logs))
      end

    end
  end
end
