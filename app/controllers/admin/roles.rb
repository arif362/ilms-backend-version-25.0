# frozen_string_literal: true

module Admin
  class Roles < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::RoleParams
    resources :roles do
      desc 'Get all Permissions'
      get 'permissions' do
         Role::PERMISSION_GROUP
      end

      desc 'Role List'
      params do
        use :pagination, per_page: 25
        optional :skip_pagination, type: Boolean, default: false
        optional :title, type: String
      end

      get do
        roles = Role.includes(:staffs).order(id: :desc)
        roles = Role.where('lower(title) LIKE ?', "%#{params[:title].downcase}%").order(id: :desc) if params[:title].present?
        authorize roles, :read?
        Admin::Entities::Roles.represent(params[:skip_pagination].present? ? roles : paginate(roles), all: true)
      end

      desc 'Get all Roles for dropdown.'
      get 'dropdown' do
        roles = Role.order(id: :desc)
        authorize roles, :skip?
        Admin::Entities::RoleDropdown.represent(roles)
      end

      desc 'Create Role'
      params do
        use :role_create_params
      end

      post do
        role = Role.new(params)
        authorize role, :create?
        role.save!
        Admin::Entities::Roles.represent(role, all: true)
      end

      route_param :id do
        desc 'Role Details'

        get do
          role = Role.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless role.present?
          authorize role, :read?
          Admin::Entities::Roles.represent(role, all: true)
        end

        desc 'Role Update'
        params do
          use :role_update_params
        end

        put do
          role = Role.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless role.present?
          authorize role, :update?

          role.update!(params)
          Admin::Entities::Roles.represent(role, all: true)
        end

        desc 'Role Delete'
        delete do
          role = Role.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless role.present?
          authorize role, :delete?
          role.destroy!
          status HTTP_CODE[:OK]
        end
      end
    end
  end
end
