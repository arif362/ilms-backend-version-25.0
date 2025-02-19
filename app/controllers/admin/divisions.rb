# frozen_string_literal: true

module Admin
  class Divisions < Admin::Base
    include Admin::Helpers::AuthorizationHelpers

    resources :divisions do
      helpers Admin::QueryParams::DivisionParams
      desc 'Divisions List'

      params do
        optional :name, type: String
      end

      get do
        divisions = if params[:name].present?
                      Division.not_deleted.where("name LIKE ?", "%#{params[:name]}%").order(name: :asc)
                    else
                      Division.not_deleted.order(name: :asc)
                    end
        authorize divisions, :read?
        Admin::Entities::Divisions.represent(divisions)
      end

      desc 'Division Create'

      params do
        use :division_create_params
      end
      post do
        division = Division.new(declared(params, include_missing: false))
        authorize division, :create?
        division.save!
        Admin::Entities::Divisions.represent(division)
      end

      desc 'Divisions dropdown List'

      get 'dropdown' do
        divisions = Division.not_deleted.order(name: :asc)
        authorize divisions, :skip?
        Admin::Entities::DivisionDropdowns.represent(divisions)
      end

      route_param :id do
        desc 'Division Details'

        get do
          division = Division.not_deleted.find_by(id: params[:id])
          error!('Division not Found', HTTP_CODE[:NOT_FOUND]) unless division.present?
          authorize division, :read?
          Admin::Entities::Divisions.represent(division)
        end

        desc 'Division Update'

        params do
          use :division_update_params
        end

        put do
          division = Division.not_deleted.find_by(id: params[:id])
          error!('Division not Found', HTTP_CODE[:NOT_FOUND]) unless division.present?
          authorize division, :update?
          division.update(declared(params, include_missing: false))
          Admin::Entities::Divisions.represent(division)
        end

        desc 'Division Delete'

        patch do
          division = Division.not_deleted.find_by(id: params[:id])
          error!('Division not Found', HTTP_CODE[:NOT_FOUND]) unless division.present?
          authorize division, :delete?
          division.update!(is_deleted: true)
        end
      end
    end
  end
end
