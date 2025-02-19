# frozen_string_literal: true

module Admin
  class Designations < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::DesignationParams
    resources :designations do

      desc 'Designations List'
      params do
        use :pagination, per_page: 25
        optional :skip_pagination, type: Boolean, default: false
      end

      get do
        designations = Designation.all.order(id: :desc)
        authorize designations, :read?
        Admin::Entities::Designations.represent(params[:skip_pagination].present? ? designations : paginate(designations))
      end

      desc 'Create Designation'
      params do
        use :designation_create_params
      end

      post do
        designation = Designation.create!(declared(params, include_missing: false))
        authorize designation, :create?
        Admin::Entities::Designations.represent(designation)
      end

      route_param :id do
        desc 'Designation Details'
        get do
          designation = Designation.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless designation.present?
          authorize designation, :read?
          Admin::Entities::Designations.represent(designation)
        end

        desc 'Designation Update'
        params do
          use :designation_update_params
        end

        put do
          designation = Designation.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless designation.present?
          authorize designation, :update?

          designation.update!(params)
          Admin::Entities::Designations.represent(designation)
        end

        desc 'Designation Delete'
        delete do
          designation = Designation.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless designation.present?
          authorize designation, :delete?
          designation.destroy!

          
        end
      end
    end
  end
end
