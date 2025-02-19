# frozen_string_literal: true

module Admin
  class Thanas < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    resources :thanas do
      helpers Admin::QueryParams::ThanaParams

      desc 'Thana List'

      params do
        optional :name, type: String
        optional :division_id
      end
      get do
        thanas = if params[:district_id].present?
                   districts = District.not_deleted.find_by(id: params[:district_id])
                   error!('District Not Found', HTTP_CODE[:NOT_FOUND]) unless districts.present?
                   district_thanas = districts.thanas.not_deleted
                   district_thanas = district_thanas.where("name LIKE ?", "%#{params[:name]}%") if params[:name].present?
                   district_thanas.order(name: :asc)
                   error!('No thana is related to this district') unless district_thanas.present?
                   district_thanas
                 else
                   all_thanas = Thana.not_deleted.order(name: :asc)
                   all_thanas = all_thanas.where("name LIKE ?", "%#{params[:name]}%") if params[:name].present?
                   all_thanas
                 end
        authorize thanas, :read?

        Admin::Entities::Thanas.represent(thanas)
      end

      desc 'Thanas Dropdown list'
      params do
        requires :district_id
      end

      get 'dropdown' do
        district = District.not_deleted.find_by(id: params[:district_id])
        error!('District Not Found', HTTP_CODE[:NOT_FOUND]) unless district.present?
        thanas = district.thanas.not_deleted.order(name: :asc)
        error!('No thana is found related to this district') unless thanas.present?
        authorize thanas, :skip?
        Admin::Entities::ThanaDropdowns.represent(thanas)
      end

      desc 'Thana Creation'
      params do
        use :thana_create_params
      end
      post do
        thana = Thana.new(declared(params, include_missing: false))
        authorize thana, :create?
        thana.save!
        Admin::Entities::Thanas.represent(thana)
      end

      route_param :id do
        desc 'Tahana Details'

        get do
          thana = Thana.not_deleted.find_by(id: params[:id])
          error!('Thana not Found', HTTP_CODE[:NOT_FOUND]) unless thana.present?
          authorize thana, :read?
          Admin::Entities::Thanas.represent(thana)
        end

        desc 'Thana Update'

        params do
          use :thana_update_params
        end

        put do
          thana = Thana.not_deleted.find_by(id: params[:id])
          error!('Thana not Found', HTTP_CODE[:NOT_FOUND]) unless thana.present?
          authorize thana, :update?
          thana.update(declared(params, include_missing: false))
          Admin::Entities::Thanas.represent(thana)
        end

        desc 'Thana Delete'

        patch do
          thana = Thana.not_deleted.find_by(id: params[:id])
          error!('Thana not Found', HTTP_CODE[:NOT_FOUND]) unless thana.present?
          authorize thana, :delete?
          thana.update!(is_deleted: true)
          success_response('Thana deleted successfully')
        end
      end
    end
  end
end
