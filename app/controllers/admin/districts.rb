# frozen_string_literal: true

module Admin
  class Districts < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    resources :districts do
      helpers Admin::QueryParams::DistrictParams

      desc 'District List'

      params do
        optional :name, type: String
        optional :division_id
      end
      get do
        districts = if params[:division_id].present?
                      division = Division.not_deleted.find_by(id: params[:division_id])
                      error!('Division Not Found', HTTP_CODE[:NOT_FOUND]) unless division.present?
                      division_districts = division.districts.not_deleted
                      division_districts = division_districts.where("name LIKE ?", "%#{params[:name]}%") if params[:name].present?
                      division_districts.order(name: :asc)
                      error!('No District Found under this Division') unless division_districts.present?
                      division_districts
                    else
                      all_districts = District.not_deleted.order(name: :asc)
                      all_districts = all_districts.where("name LIKE ?", "%#{params[:name]}%") if params[:name].present?
                      all_districts
                   end
        authorize districts, :read?
        Admin::Entities::Districts.represent(districts)
      end

      desc 'District dropdown List'
      params do
        requires :division_id
      end

      get 'dropdown' do
        division = Division.not_deleted.find_by(id: params[:division_id])
        error!('Division Not Found', HTTP_CODE[:NOT_FOUND]) unless division.present?
        districts = division.districts.not_deleted.order(name: :asc)
        error!('No District Found under this Division') unless districts.present?
        authorize districts, :skip?
        Admin::Entities::DistrictDropdowns.represent(districts)
      end

      desc 'district Creation'
      params do
        use :district_create_params
      end
      post do
        division = Division.not_deleted.find_by(id: params[:division_id])
        error!('Division Not Found', HTTP_CODE[:NOT_FOUND]) unless division.present?
        district = District.new(declared(params, include_missing: false))
        authorize district, :create?
        district.save!
        Admin::Entities::Districts.represent(district)
      end

      route_param :id do
        desc 'District Details'

        get do
          district = District.not_deleted.find_by(id: params[:id])
          error!('Division not Found', HTTP_CODE[:NOT_FOUND]) unless district.present?
          authorize districts, :read?
          Admin::Entities::Districts.represent(district)
        end

        desc 'Division Update'

        params do
          use :district_update_params
        end

        put do
          district = District.not_deleted.find_by(id: params[:id])
          error!('District not Found', HTTP_CODE[:NOT_FOUND]) unless district.present?
          authorize district, :update?
          division.update(declared(params, include_missing: false))
          Admin::Entities::Districts.represent(division)
        end

        desc 'District Delete'

        patch do
          division = District.not_deleted.find_by(id: params[:id])
          error!('District not Found', HTTP_CODE[:NOT_FOUND]) unless division.present?
          authorize districts, :delete?
          division.update!(is_deleted: true)
          success_response('District deleted successfully')
        end
      end
    end
  end
end
