# frozen_string_literal: true

module Admin
  class PublisherBiblios < Admin::Base
    include Admin::Helpers::AuthorizationHelpers

    resource :publisher_biblios do
      desc 'Get a list of publisher_biblios'
      params do
        use :pagination, per_page: 25
        optional :is_shortlisted, type: Boolean, allow_blank: false
        requires :memorandum_id, type: Integer, allow_blank: false
        requires :publisher_id, type: Integer, allow_blank: false
      end
      get do
        memorandum = Memorandum.not_deleted.find_by(id: params[:memorandum_id])
        error!('Memorandum not found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?

        publisher = Publisher.find_by(id: params[:publisher_id])
        error!('Publisher not found', HTTP_CODE[:NOT_FOUND]) unless publisher.present?

        publisher_biblios = publisher.publisher_biblios
        publisher_biblios = publisher_biblios.where(is_shortlisted: true) if params[:is_shortlisted] == true

        Admin::Entities::PublisherBiblioList.represent(paginate(publisher_biblios.order(title: :asc)))
      end

      desc 'Memorandum publisher shorlist'

      params do
        requires :memorandum_id, type: Integer, allow_blank: false
        requires :publisher_id, type: Integer, allow_blank: false
        requires :publisher_biblio_ids, type: Array[Integer], allow_blank: false
      end

      put 'shortlist' do
        publisher_biblios = []
        memorandum = Memorandum.not_deleted.find_by(id: params[:memorandum_id])
        error!('Memorandum not found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?

        memorandum_publisher = memorandum.memorandum_publishers.submitted.find_by(publisher_id: params[:publisher_id])

        unless memorandum_publisher.present?
          error!("Publisher not found under the memorandum no #{params[:memorandum_id]}", HTTP_CODE[:NOT_FOUND])
        end


        ActiveRecord::Base.transaction do
          memorandum_publisher.update!(is_shortlisted: true)
          params[:publisher_biblio_ids].each do |publisher_biblio_id|
            publisher_biblio = PublisherBiblio.find(publisher_biblio_id)
            authorize memorandum_publisher, :update?
            publisher_biblio.update!(is_shortlisted: true)
            publisher_biblios << publisher_biblio
          end
        end
        Admin::Entities::PublisherBiblioList.represent(publisher_biblios)
      end

    end
  end
end
