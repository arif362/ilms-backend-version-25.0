# frozen_string_literal: true

module PublicLibrary
  class RequestedBiblios < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::RequestedBibliosParams
    resources :requested_biblios do
      desc 'request for a biblio'
      params do
        use :requested_biblios_create_params
      end

      post do
        if !params[:isbn].present? && params.count < 2
          error!('Minimum two fields are required', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        requested_biblios = @current_user.unique_requested_biblio(params)
        unless requested_biblios.blank?
          error!('Demand request already exist for provided information', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        requested_biblio = RequestedBiblio.new(declared(params, include_missing: false)
                                                 .merge!(user_id: @current_user.id, created_by: @current_user, updated_by: @current_user))
        unless params[:author_requested_biblios_attributes].blank?
          params[:author_requested_biblios_attributes].each do |author_requested_biblio|
            author = Author.find_by(id: author_requested_biblio[:author_id])
            error!('Author not found', HTTP_CODE[:NOT_FOUND]) unless author.present?
          end
        end
        unless params[:biblio_subject_requested_biblios_attributes].blank?
          params[:biblio_subject_requested_biblios_attributes].each do |biblio_subject_requested_biblio|
            biblio_subject = BiblioSubject.find_by(id: biblio_subject_requested_biblio[:biblio_subject_id])
            error!('Biblio subject not found', HTTP_CODE[:NOT_FOUND]) unless biblio_subject.present?
          end
        end
        requested_biblio.save!
        PublicLibrary::Entities::RequestedBiblioDetails.represent(requested_biblio,
                                                                  locale: @locale,
                                                                  request_source: @request_source)
      end

      desc 'requestd biblio list for user'

      get do
        requested_biblos = @current_user.requested_biblios.order(id: :desc)
        PublicLibrary::Entities::RequestedBiblios.represent(requested_biblos)
      end

      route_param :id do
        get do
          requested_biblo = @current_user.requested_biblios.find_by(id: params[:id])
          error!('Requested boblio not found', HTTP_CODE[:NOT_FOUND]) unless requested_biblo.present?
          PublicLibrary::Entities::RequestedBiblioDetails.represent(requested_biblo,
                                                                    locale: @locale,
                                                                    request_source: @request_source)
        end
      end
    end
  end
end
