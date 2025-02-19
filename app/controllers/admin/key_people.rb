# frozen_string_literal: true

module Admin
  class KeyPeople < Admin::Base
    resources :key_people do
      include Admin::Helpers::AuthorizationHelpers
      helpers Admin::QueryParams::KeyPersonParams
      desc 'Key People List'
      params do
        use :pagination, per_page: 25
      end
      get do
        key_people = KeyPerson.not_deleted.all
        authorize key_people, :read?
        Admin::Entities::KeyPeople.represent(key_people.order(id: :desc))
      end

      desc 'Create key person'
      params do
        use :key_person_create_params
      end

      post do
        error!('Position must be positive', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:position].positive?
        key_person = KeyPerson.new(declared(params, include_missing: false))
        authorize key_person, :create?
        key_person.save!
        Admin::Entities::KeyPersonDetails.represent(key_person)
      end

      route_param :id do
        desc 'Key person details'

        get do
          key_person = KeyPerson.not_deleted.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless key_person.present?
          authorize key_person, :read?
          Admin::Entities::KeyPersonDetails.represent(key_person)
        end

        desc 'Key person update'
        params do
          use :key_person_update_params
        end

        put do
          key_person = KeyPerson.not_deleted.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless key_person.present?
          unless key_person.check_slug_uniqueness(params[:slug])
            error!('Slug must be unique', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          authorize key_person, :update?
          key_person.update!(declared(params, include_missing: false))
          Admin::Entities::KeyPersonDetails.represent(key_person)
        end

        desc 'Key person delete'

        delete do
          key_person = KeyPerson.not_deleted.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless key_person.present?
          authorize key_person, :delete?
          key_person.update!(is_deleted: true)
          { message: 'Successfully deleted' }
        end
      end
    end
  end
end
