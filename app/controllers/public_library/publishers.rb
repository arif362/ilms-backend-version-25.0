# frozen_string_literal: true

module PublicLibrary
  class Publishers < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::PublisherParams
    resources :publishers do
      desc 'Create Publisher'
      params do
        use :publisher_create_params
      end
      post do
        error!('Already a publisher', HTTP_CODE[:NOT_ACCEPTABLE]) if @current_user.publisher?
        if @current_user.create_publisher!(declared(params, include_missing: false))
          PublicLibrary::Entities::Publishers.represent(@current_user.publisher)
        end
      end

      desc 'publisher Details'
      get '/details' do
        error!('Publisher Not Found', HTTP_CODE[:NOT_FOUND]) if @current_user.publisher.nil?
        PublicLibrary::Entities::Publishers.represent(@current_user.publisher)
      end

      route_param :id do
        desc 'Updating Publisher'
        params do
          use :publisher_update_params
        end
        put do
          publisher = @current_user.publisher
          error!('Publisher Not Found', HTTP_CODE[:NOT_FOUND]) if publisher.nil?
          PublicLibrary::Entities::Publishers.represent(publisher) if publisher.update!(declared(params,
                                                                                                include_missing: false))
        end
      end
    end
  end
end
