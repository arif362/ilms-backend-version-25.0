# frozen_string_literal: true

module PublicLibrary
  class KeyPeople < PublicLibrary::Base
    resources :key_people do
      desc 'Key People List'
      params do
        use :pagination, per_page: 25
        optional :count, type: Integer
      end
      route_setting :authentication, optional: true
      get do
        key_people = KeyPerson.not_deleted.active.all.order(position: :asc)
        if params[:count].present?
          error!('Count must be greater than zero', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:count].positive?
          key_people = key_people.first(params[:count])
        end
        PublicLibrary::Entities::KeyPersonDetails.represent(key_people,
                                                            request_source: @request_source, locale: @locale)
      end

      desc 'Key People Details'

      route_setting :authentication, optional: true
      route_param :slug do
        get do
          key_people = KeyPerson.not_deleted.active.find_by(slug: params[:slug])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless key_people.present?
          PublicLibrary::Entities::KeyPersonDetails.represent(key_people,
                                                              request_source: @request_source, locale: @locale)
        end
      end
    end
  end
end
