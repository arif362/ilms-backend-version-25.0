# frozen_string_literal: true

module PublicLibrary
  class MemorandumPublishers < PublicLibrary::Base
    resources :memorandum_publishers do
      desc 'Memorandum publisher list'
      params do
        use :pagination, per_page: 25
        optional :tender_session, type: String, regexp: /\A[1-9]\d{3}-[1-9]\d{3}\z/
      end

      get do
        error!('User is not a publisher', HTTP_CODE[:NOT_FOUND]) unless @current_user.publisher?
        memorandum_publishers = MemorandumPublisher.submitted.where(publisher_id: @current_user.publisher.id)
        if params[:tender_session].present?
          unless params[:tender_session].split('-').then { |first, second| second.to_i == first.to_i + 1 }
            error!('Invalid tender session format', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          memorandum = Memorandum.find_by(tender_session: params[:tender_session])
          error!('Memorandum not found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?
          memorandum_publishers = memorandum_publishers.where(memorandum_id: memorandum.id)
        end
        PublicLibrary::Entities::MemorandumPublishers.represent(paginate(memorandum_publishers.order(id: :desc)))
      end

      route_param :id do
        desc 'Memorandum publisher details'

        get do
          error!('User is not a publisher', HTTP_CODE[:NOT_FOUND]) unless @current_user.publisher?
          memorandum_publisher = MemorandumPublisher.find_by(id: params[:id],
                                                             publisher_id: @current_user.publisher.id)
          error!('Memorandum publisher not found', HTTP_CODE[:NOT_FOUND]) unless memorandum_publisher.present?
          PublicLibrary::Entities::MemorandumPublisherDetails.represent(memorandum_publisher)
        end
      end

      desc 'Memorandum publisher submit application'

      params do
        requires :memorandum_id, type: Integer
      end
      put 'submit' do
        error!('User is not a publisher', HTTP_CODE[:NOT_FOUND]) unless @current_user.publisher?
        memorandum = Memorandum.find_by(id: params[:memorandum_id])
        memorandum_publisher = memorandum.memorandum_publishers
                                         .find_by(publisher_id: @current_user.publisher.id,
                                                  is_final_submitted: false)
        error!('Memorandum publisher not found', HTTP_CODE[:NOT_FOUND]) unless memorandum_publisher.present?
        unless memorandum_publisher.publisher_biblios.present?
          error!('Memorandum publisher doesn\'t have any biblio', HTTP_CODE[:NOT_FOUND])
        end
        memorandum_publisher.update!(is_final_submitted: true, submitted_at: DateTime.now)
        PublicLibrary::Entities::MemorandumPublisherDetails.represent(memorandum_publisher)
      end
    end
  end
end
