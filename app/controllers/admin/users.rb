# frozen_string_literal: true

module Admin
  class Users < Admin::Base
    resources :users do
      include Admin::Helpers::AuthorizationHelpers
      helpers Admin::QueryParams::UserParams

      desc 'Registered Users List'
      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String
        optional :gender, type: String, values: %w[male female other]
      end

      get do
        users = if params[:search_term].present?
                  if params[:search_term].starts_with?('R', 'r')
                    User.where(id: params[:search_term][2..].to_i)
                  else
                    User.search_unique_id_or_phone(params[:search_term])
                  end
                else
                  User.all
                end
        users = users.where(gender: params[:gender]) if params[:gender].present?
        authorize users, :read?
        Admin::Entities::UserList.represent(paginate(users.order(id: :desc)))
      end

      route_param :id do
        desc 'User Details'
        get do
          user = User.find_by(id: params[:id])
          error!('Not Found', 404) unless user.present?
          authorize user, :read?
          Admin::Entities::UserList.represent(user)
        end

        desc 'User Update'
        params do
          use :user_update_params
        end
        put do
          user = User.find_by(id: params[:id])
          error!('Not Found', 404) unless user.present?
          authorize user, :update?
          user.update!(declared(params, include_missing: false).merge!(updated_by: @current_staff))
          Admin::Entities::UserList.represent(user)
        end
      end
    end
  end
end
