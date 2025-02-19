# frozen_string_literal: true

module Admin
  class MemorandumPublishers < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::MemorandumPublisherParams

    resources :memorandum_publishers do
      desc 'Memorandum publisher list'
      params do
        use :pagination, per_page: 25
        requires :memorandum_id, type: Integer
        optional :is_shortlisted, type: Boolean, values: [true]
      end

      get do
        memorandum = Memorandum.not_deleted.find_by(id: params[:memorandum_id])
        error!('Memorandum not found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?
        memorandum_publishers = MemorandumPublisher.submitted.where(memorandum_id: memorandum.id)
        memorandum_publishers = memorandum_publishers.shortlisted if params[:is_shortlisted].present?
        authorize memorandum_publishers, :read?
        Admin::Entities::MemorandumPublishers.represent(paginate(memorandum_publishers))
      end

      route_param :id do
        desc 'Memorandum publisher details'

        get do
          memorandum_publisher = MemorandumPublisher.find_by(id: params[:id])
          error!('Memorandum publisher not found', HTTP_CODE[:NOT_FOUND]) unless memorandum_publisher.present?
          authorize memorandum_publisher, :read?
          Admin::Entities::MemorandumPublisherDetails.represent(memorandum_publisher)
        end

        resources :publisher_biblios do
          desc 'Shorlist publisher biblios'
          params do
            use :publisher_biblio_shortlist_params
          end

          put 'shortlist' do
            publisher_biblios = []
            memorandum_publisher = MemorandumPublisher.find_by(id: params[:id])
            error!('Memorandum publisher not found', HTTP_CODE[:NOT_FOUND]) unless memorandum_publisher.present?
            ActiveRecord::Base.transaction do
              params[:publisher_biblio_ids].each do |publisher_biblio_id|
                publisher_biblio = PublisherBiblio.find_by(id: publisher_biblio_id,
                                                           memorandum_publisher_id: memorandum_publisher.id)
                unless publisher_biblio.present?
                  error!('Publisher biblio not found for the given memorandum publisher', HTTP_CODE[:NOT_FOUND])
                end

                authorize publisher_biblio, :update?
                publisher_biblio.update!(is_shortlisted: true)
                publisher_biblios << publisher_biblio
              end
            end
            Admin::Entities::PublisherBiblioDetails.represent(publisher_biblios)
          end
        end
      end
    end
  end
end
