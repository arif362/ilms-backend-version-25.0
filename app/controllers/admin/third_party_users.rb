# frozen_string_literal: true

module Admin
  class ThirdPartyUsers < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::ThirdPartyParams
    resources :third_party_users do
      desc 'Third party List'
      params do
        use :pagination, per_page: 25
      end

      get do
        third_party_users = ThirdPartyUser.all
        authorize third_party_users, :read?
        third_party_users = third_party_users.where('name LIKE ?', "%#{params[:name]}%") if params[:name].present?
        Admin::Entities::ThirdPartyUsers.represent(paginate(third_party_users.order(id: :desc)))
      end

      desc 'Create Three ps'
      params do
        use :third_party_create_params
      end

      post do
        if params[:password] != params[:password_confirmation]
          error!('Password didn\'t match', HTTP_CODE[:NOT_ACCEPTABLE])
        end

        unless ThirdPartyUser.find_by(email: params[:email]).blank?
          error!('Email already exists', HTTP_CODE[:NOT_ACCEPTABLE])
        end

        unless ThirdPartyUser.find_by(phone: params[:phone]).blank?
          error!('Phone number already exists', HTTP_CODE[:NOT_ACCEPTABLE])
        end

        third_party_user = ThirdPartyUser.new(declared(params).merge!(created_by: @current_staff.id))
        authorize third_party_user, :create?

        Admin::Entities::ThirdPartyUsers.represent(third_party_user) if third_party_user.save!
      end

      route_param :id do
        desc 'Third party user details'
        get do
          third_party_user = ThirdPartyUser.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless ThirdPartyUser.present?
          authorize third_party_user, :read?
          Admin::Entities::ThirdPartyUsers.represent(third_party_user)
        end

        desc 'Staff Update'
        params do
          use :third_party_update_params
        end

        put do
          third_party_user = ThirdPartyUser.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless ThirdPartyUser.present?
          authorize third_party_user, :update?

          third_party_user.update!(declared(params).merge!(updated_by: @current_staff.id))
          Admin::Entities::ThirdPartyUsers.represent(third_party_user)
        end

        desc 'Staff Delete'
        delete do
          third_party_user = ThirdPartyUser.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless ThirdPartyUser.present?
          authorize third_party_user, :delete?

          if third_party_user.update!(is_deleted: true, updated_by: @current_staff.id)
            Admin::Entities::ThirdPartyUsers.represent(staff)
          end
        end
      end
    end
  end
end
