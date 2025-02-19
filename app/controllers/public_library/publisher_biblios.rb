# frozen_string_literal: true

module PublicLibrary
  class PublisherBiblios < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::PublisherBiblioParams

    resources :publisher_biblios do
      desc 'Publisher biblios list'

      params do
        use :pagination, per_page: 25
        requires :memorandum_id, type: Integer
      end

      get do
        error!('User is not a publisher', HTTP_CODE[:NOT_FOUND]) unless @current_user.publisher?
        memorandum = Memorandum.not_deleted.find_by(id: params[:memorandum_id])
        error!('Memorandum not found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?
        memorandum_publisher = MemorandumPublisher.find_by(publisher_id: @current_user.publisher.id,
                                                           memorandum_id: memorandum.id)
        if memorandum_publisher.present?
          publisher_biblios = memorandum_publisher.publisher_biblios.order(id: :desc)
          PublicLibrary::Entities::PublisherBiblios.represent(paginate(publisher_biblios))
        else
          []
        end
      end

      desc 'Create publisher biblio'

      params do
        use :publisher_biblio_create_params
      end

      post do
        error!('User is not a publisher', HTTP_CODE[:NOT_FOUND]) unless @current_user.publisher?
        memorandum = Memorandum.not_deleted.find_by(id: params[:memorandum_id])
        error!('Memorandum not found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?
        memorandum_publisher = MemorandumPublisher.find_or_create_by!(publisher_id: @current_user.publisher.id,
                                                                      memorandum_id: memorandum.id)
        publisher_biblio = memorandum_publisher.publisher_biblios.build(declared(params, include_missing: false)
                                                                          .except(:memorandum_id))
        if publisher_biblio.save!
          PublicLibrary::Entities::PublisherBiblioDetails.represent(publisher_biblio, expose_memorandum: true)
        end
      end

      route_param :id do
        desc 'Publisher biblio details'

        get do
          error!('User is not a publisher', HTTP_CODE[:NOT_FOUND]) unless @current_user.publisher?
          memorandum_publishers = MemorandumPublisher.where(publisher_id: @current_user.publisher.id)
          error!('Publisher have no application', HTTP_CODE[:NOT_FOUND]) unless memorandum_publishers.present?
          publisher_biblio = PublisherBiblio.find_by(id: params[:id], memorandum_publisher_id: memorandum_publishers.ids)
          error!('Publisher biblio not found', HTTP_CODE[:NOT_FOUND]) unless publisher_biblio.present?
          PublicLibrary::Entities::PublisherBiblioDetails.represent(publisher_biblio, expose_memorandum: true)
        end

        desc 'Update publisher biblio'

        params do
          use :publisher_biblio_update_params
        end

        put do
          error!('User is not a publisher', HTTP_CODE[:NOT_FOUND]) unless @current_user.publisher?
          publisher_biblio = @current_user.publisher.publisher_biblios.find_by(id: params[:id])
          error!('Publisher biblio not found', HTTP_CODE[:NOT_FOUND]) unless publisher_biblio.present?
          if publisher_biblio.memorandum_publisher.is_final_submitted
            error!('Already submitted. Cannot be updated anymore.', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          publisher_biblio.update!(declared(params, include_missing: false))
          PublicLibrary::Entities::PublisherBiblioDetails.represent(publisher_biblio, expose_memorandum: true)
        end

        desc 'Delete publisher biblio'

        delete do
          error!('User is not a publisher', HTTP_CODE[:NOT_FOUND]) unless @current_user.publisher?
          publisher_biblio = @current_user.publisher.publisher_biblios.find_by(id: params[:id])
          error!('Publisher biblio not found', HTTP_CODE[:NOT_FOUND]) unless publisher_biblio.present?
          if publisher_biblio.memorandum_publisher.is_final_submitted
            error!('Already submitted. Cannot be deleted anymore.', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          publisher_biblio.destroy!
          PublicLibrary::Entities::PublisherBiblioDetails.represent(publisher_biblio, expose_memorandum: true)
        end
      end
    end
  end
end
