# frozen_string_literal: true

module Admin
  class LibraryEntryLogs < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    resources :library_entry_logs do
      desc 'Library entry logs List'
      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String
        optional :library_code, type: String
        optional :thana_id, type: String
        optional :district_id, type: String
        optional :age, type: Integer
        optional :start_at, type: String
        optional :end_at, type: String
        optional :membership_category, type: String, values: %w[general student child]
        optional :gender, type: String, values: %w[male female other]
      end

      get do
        library_entry_logs = LibraryEntryLog.all

        if params[:search_term].present?
          if params[:search_term].starts_with?('T-', 't-')
            guest = Guest.find_by(id: params[:search_term][2..].to_i)
            library_entry_logs = library_entry_logs.where(entryable_id: guest&.id, entryable_type: 'Guest')
          elsif params[:search_term].starts_with?('R-', 'r-')
            user = User.find_by(id: params[:search_term][2..].to_i)
            library_entry_logs = library_entry_logs.where(entryable_id: user&.id, entryable_type: 'User')
          else
            search_term = params[:search_term].downcase
            library_entry_logs = library_entry_logs.where('name like :q OR email like :q or phone like :q', q: "%#{search_term}%")
          end
        end

        library_entry_logs = library_entry_logs.where(gender: params[:gender]) if params[:gender].present?
        library_entry_logs = library_entry_logs.where(age: params[:age]) if params[:age].present?
        if params[:start_at].present? && params[:end_at].present?
          library_entry_logs = library_entry_logs.where(created_at: params[:start_at].to_datetime..params[:end_at].to_datetime)
        end

        if params[:library_code].present?
          library = Library.find_by(code: params[:library_code])
          library_entry_logs = library_entry_logs.where(library_id: library&.id)
        end
        if params[:district_id].present?
          district = District.find_by(name: params[:district_id])
          library_entry_logs = library_entry_logs.where(district_id: district&.id)
        end
        if params[:thana_id].present?
          thana = Thana.find_by(name: params[:thana_id])
          library_entry_logs = library_entry_logs.where(thana_id: thana&.id)
        end

        authorize library_entry_logs, :read?
        Admin::Entities::LibraryEntryLogs.represent(paginate(library_entry_logs.order(id: :desc)))
      end

      route_param :id do
        desc 'library entry log Details'
        get do
          library_entry_log = LibraryEntryLog.find_by(id: params[:id])
          error!('Not Found', 404) unless library_entry_log.present?
          authorize library_entry_log, :read?
          Admin::Entities::LibraryEntryLogs.represent(library_entry_log)
        end
      end
    end
  end
end
