# frozen_string_literal: true

module Admin
  class Circulations < Admin::Base
    resources :circulations do
      include Admin::Helpers::AuthorizationHelpers
      desc 'lost circulations List'
      params do
        use :pagination, per_page: 25
        optional :library_code, type: String
        optional :status, type: String, values: %w[lost]
      end
      get 'lost' do
        circulation_status = CirculationStatus.get_status(CirculationStatus.status_keys[:lost])
        error!('Invalid status', HTTP_CODE[:NOT_ACCEPTABLE]) unless circulation_status.present?
        circulations = Circulation.where(circulation_status_id: circulation_status.id)
        if params[:status].present?
          unless CirculationStatus.status_keys.include?(params[:status])
            error!('Status invalid', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          status = CirculationStatus.find_by(system_status: params[:status])
          circulations.where(circulation_status_id: status.id)
        end
        authorize circulations, :read?
        Admin::Entities::Circulations.represent(paginate(circulations.order(id: :desc)))
      end
    end
  end
end
